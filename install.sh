#!/usr/bin/env bash
# install.sh - Unified dotfiles installer with dependency management and backup
# Works on Arch, Debian/Ubuntu, Fedora/RHEL, macOS, and GitHub Codespaces
#
# This is the single entrypoint for dotfiles setup:
#   1. Self-bootstraps (installs stow + yq if missing)
#   2. Reads config.yaml (modules[] + machines[] schema)
#   3. Installs per-module dependencies from deps.yaml
#   4. Backs up conflicting files and stows modules
#
# Usage: ./install.sh
# Idempotent: safe to run repeatedly.

set -euo pipefail

# ============================================================================
# CONSTANTS
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.yaml"
CURRENT_HOST=""  # set after core utilities are verified
BACKUP_DIR=""  # set lazily on first conflict
BACKUP_TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
DRY_RUN="${DRY_RUN:-false}"

# Counters for summary
declare -i MODULES_STOWED=0
declare -i PACKAGES_INSTALLED=0
declare -i CARGO_INSTALLED=0
declare -i PIP_INSTALLED=0
declare -i SCRIPTS_RUN=0
declare -i FILES_BACKED_UP=0
declare -a ERRORS=()
declare -a STOWED_MODULES=()
declare -A DISCOVERED_MODULES

# ============================================================================
# COLOR LOGGING
# ============================================================================

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Trap errors with context
trap 'error "Script failed at line $LINENO (exit code $?)"' ERR

# ============================================================================
# DISTRO / PACKAGE MANAGER DETECTION
# ============================================================================

detect_distro() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        echo "macos"
    elif [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        echo "${ID}"
    else
        echo "unknown"
    fi
}

get_package_manager() {
    local distro="$1"
    case "$distro" in
        arch|manjaro|endeavouros|cachyos)
            echo "pacman" ;;
        ubuntu|debian|pop|linuxmint)
            echo "apt" ;;
        fedora|rhel|centos|rocky|almalinux)
            echo "dnf" ;;
        macos)
            echo "brew" ;;
        *)
            # Fallback: probe for binaries
            if   command -v pacman   >/dev/null 2>&1; then echo "pacman"
            elif command -v apt-get  >/dev/null 2>&1; then echo "apt"
            elif command -v dnf      >/dev/null 2>&1; then echo "dnf"
            elif command -v yum      >/dev/null 2>&1; then echo "yum"
            elif command -v brew     >/dev/null 2>&1; then echo "brew"
            else echo "unknown"
            fi
            ;;
    esac
}

get_deps_os_key() {
    local pkg_mgr="$1"
    case "$pkg_mgr" in
        pacman)  echo "arch"   ;;
        apt)     echo "debian" ;;
        dnf|yum) echo "fedora" ;;
        brew)    echo "macos"  ;;
        *)       echo ""       ;;
    esac
}

# ============================================================================
# PACKAGE INSTALLATION HELPERS
# ============================================================================

# Check if a native package is already installed.
# Returns 0 if installed, 1 if not.
is_package_installed() {
    local pkg_mgr="$1"
    local pkg="$2"

    case "$pkg_mgr" in
        pacman)  pacman -Qq "$pkg" &>/dev/null ;;
        apt)     dpkg -s "$pkg" &>/dev/null ;;
        dnf|yum) rpm -q "$pkg" &>/dev/null ;;
        brew)    brew list "$pkg" &>/dev/null ;;
        *)       return 1 ;;
    esac
}

# Install native packages via the detected package manager.
# Filters out already-installed packages to avoid unnecessary sudo prompts.
install_native_packages() {
    local pkg_mgr="$1"
    shift
    local -a pkgs=("$@")

    if [[ ${#pkgs[@]} -eq 0 ]]; then
        return 0
    fi

    # Filter out already-installed packages
    local -a missing_pkgs=()
    for pkg in "${pkgs[@]}"; do
        if ! is_package_installed "$pkg_mgr" "$pkg"; then
            missing_pkgs+=("$pkg")
        fi
    done

    if [[ ${#missing_pkgs[@]} -eq 0 ]]; then
        info "  All packages already installed: ${pkgs[*]}"
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        info "  [DRY-RUN] Would install: ${missing_pkgs[*]}"
        return 0
    fi

    info "  Installing native packages: ${missing_pkgs[*]}"

    case "$pkg_mgr" in
        pacman)
            sudo pacman -Sy --noconfirm --needed "${missing_pkgs[@]}" || {
                warn "Some pacman packages may have failed"
                return 1
            }
            ;;
        apt)
            sudo apt-get update -qq || warn "apt-get update had errors (non-fatal, continuing)"
            sudo apt-get install -y -qq "${missing_pkgs[@]}" || {
                warn "Some apt packages may not be available"
                return 1
            }
            ;;
        dnf)
            sudo dnf install -y -q "${missing_pkgs[@]}" || {
                warn "Some dnf packages may not be available"
                return 1
            }
            ;;
        yum)
            sudo yum install -y -q "${missing_pkgs[@]}" || {
                warn "Some yum packages may not be available"
                return 1
            }
            ;;
        brew)
            brew install "${missing_pkgs[@]}" || {
                warn "Some brew packages may not be available"
                return 1
            }
            ;;
        *)
            error "Unsupported package manager: $pkg_mgr"
            error "Please install manually: ${missing_pkgs[*]}"
            return 1
            ;;
    esac
}

# Install AUR packages via yay or paru (Arch-only, no sudo).
install_aur_packages() {
    local -a pkgs=("$@")

    if [[ ${#pkgs[@]} -eq 0 ]]; then
        return 0
    fi

    # Only relevant on Arch-based systems
    if [[ "$PKG_MGR" != "pacman" ]]; then
        return 0
    fi

    # Filter out already-installed packages
    local -a missing_pkgs=()
    for pkg in "${pkgs[@]}"; do
        if ! pacman -Qq "$pkg" &>/dev/null; then
            missing_pkgs+=("$pkg")
        fi
    done

    if [[ ${#missing_pkgs[@]} -eq 0 ]]; then
        info "  All AUR packages already installed: ${pkgs[*]}"
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        info "  [DRY-RUN] Would install from AUR: ${missing_pkgs[*]}"
        return 0
    fi

    # Detect AUR helper
    local aur_helper=""
    if command -v paru &>/dev/null; then
        aur_helper="paru"
    elif command -v yay &>/dev/null; then
        aur_helper="yay"
    else
        warn "  AUR packages needed but no AUR helper (paru/yay) found: ${missing_pkgs[*]}"
        warn "  Install paru or yay, then re-run install.sh"
        return 1
    fi

    info "  Installing AUR packages via $aur_helper: ${missing_pkgs[*]}"
    "$aur_helper" -S --noconfirm --needed "${missing_pkgs[@]}" || {
        warn "Some AUR packages may have failed"
        return 1
    }
}

# Install cargo packages. Runs as the current user (no sudo).
install_cargo_packages() {
    local -a pkgs=("$@")

    if [[ ${#pkgs[@]} -eq 0 ]]; then
        return 0
    fi

    if ! command -v cargo >/dev/null 2>&1; then
        warn "  cargo not found -- skipping cargo packages: ${pkgs[*]}"
        warn "  Install Rust (https://rustup.rs) and re-run to install these"
        return 0
    fi

    local -a missing=()
    for pkg in "${pkgs[@]}"; do
        if ! cargo install --list 2>/dev/null | grep -q "^${pkg} "; then
            missing+=("$pkg")
        fi
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        info "  All cargo packages already installed"
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        info "  [DRY-RUN] Would install via cargo: ${missing[*]}"
        return 0
    fi

    info "  Installing cargo packages: ${missing[*]}"
    for pkg in "${missing[@]}"; do
        if cargo install "$pkg"; then
            CARGO_INSTALLED+=1
        else
            warn "  Failed to install cargo package: $pkg"
            ERRORS+=("cargo install $pkg failed")
        fi
    done
}

# Install pip packages. Runs as the current user (no sudo).
install_pip_packages() {
    local -a pkgs=("$@")

    if [[ ${#pkgs[@]} -eq 0 ]]; then
        return 0
    fi

    if ! command -v pip3 >/dev/null 2>&1 && ! command -v pip >/dev/null 2>&1; then
        warn "  pip not found -- skipping pip packages: ${pkgs[*]}"
        return 0
    fi

    local pip_cmd="pip3"
    if ! command -v pip3 >/dev/null 2>&1; then
        pip_cmd="pip"
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        info "  [DRY-RUN] Would install via pip: ${pkgs[*]}"
        return 0
    fi

    info "  Installing pip packages: ${pkgs[*]}"
    if $pip_cmd install --user "${pkgs[@]}"; then
        PIP_INSTALLED+=${#pkgs[@]}
    else
        warn "  Some pip packages may have failed"
        ERRORS+=("pip install failed for some packages")
    fi
}

# ============================================================================
# BACKUP HELPERS
# ============================================================================

# Ensure backup directory exists; create once with timestamp
ensure_backup_dir() {
    if [[ -z "$BACKUP_DIR" ]]; then
        BACKUP_DIR="$HOME/.dotfiles-backup/$BACKUP_TIMESTAMP"
        mkdir -p "$BACKUP_DIR"
    fi
}

# Back up a single file or directory (only real files, not symlinks).
# Returns 0 if backed up, 1 if skipped.
backup_file() {
    local file="$1"
    local target_dir="$2"

    if [[ ! -e "$file" ]] || [[ -L "$file" ]]; then
        return 1
    fi

    ensure_backup_dir

    local rel_path="${file#"$target_dir"/}"
    local backup_target="$BACKUP_DIR/$rel_path"
    mkdir -p "$(dirname "$backup_target")"

    if [[ -d "$file" ]]; then
        cp -r "$file" "$backup_target"
    else
        cp "$file" "$backup_target"
    fi

    info "  Backed up: $rel_path"
    FILES_BACKED_UP+=1
    return 0
}

# Scan for files that would conflict with stow, back them up, and remove them
# so stow can proceed cleanly.
backup_conflicts_for_module() {
    local module_path="$1"
    local target_dir="$2"

    # Walk through the module directory and check each corresponding target path
    while IFS= read -r -d '' src_file; do
        local rel="${src_file#"$module_path"/}"
        local target_file="$target_dir/$rel"

        # Only care about real files (not symlinks) that would conflict
        if [[ -e "$target_file" && ! -L "$target_file" ]]; then
            backup_file "$target_file" "$target_dir"
            rm -rf "$target_file"
        fi
    done < <(find "$module_path" -not -name '.stow-local-ignore' -not -path '*/.git/*' -type f -print0 2>/dev/null)
}

# ============================================================================
# CORE UTILITIES CHECK: verify essential commands are available
# ============================================================================

# ============================================================================
# PREREQUISITE CHECK AND AUTO-INSTALL
# ============================================================================

check_and_install_prerequisites() {
    info "Checking prerequisites..."

    # Check core utilities (fail-fast if missing)
    local -a missing_core=()
    for cmd in stow yq git find grep sed date mkdir cp rm; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_core+=("$cmd")
        fi
    done

    if [[ ${#missing_core[@]} -gt 0 ]]; then
        error "Missing required tools: ${missing_core[*]}"
        error "Install via your package manager:"
        case "$PKG_MGR" in
            pacman) error "  sudo pacman -S stow yq git" ;;
            apt)    error "  sudo apt-get install stow yq git" ;;
            dnf)    error "  sudo dnf install stow yq git" ;;
            brew)   error "  brew install stow yq git" ;;
        esac
        exit 1
    fi

    # Check hostname command specifically
    if ! command -v hostname >/dev/null 2>&1; then
        case "$PKG_MGR" in
            pacman) missing_core+=("inetutils") ;;
            *)      missing_core+=("hostname") ;;
        esac
        error "Missing hostname command. Install: ${missing_core[*]}"
        exit 1
    fi

    # Auto-install cargo if missing
    if ! command -v cargo >/dev/null 2>&1; then
        info "Installing Rust via rustup (non-interactive, no sudo)..."
        if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path; then
            # shellcheck source=/dev/null
            [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
            success "Cargo installed"
        else
            warn "Failed to install cargo - cargo: packages will be skipped"
        fi
    fi

    # Check Python/pip (fail-fast if missing)
    if ! command -v pip3 >/dev/null 2>&1 && ! command -v pip >/dev/null 2>&1; then
        error "Python pip not found"
        error "Install via your package manager:"
        case "$PKG_MGR" in
            pacman) error "  sudo pacman -S python-pip" ;;
            apt)    error "  sudo apt-get install python3-pip" ;;
            dnf)    error "  sudo dnf install python3-pip" ;;
            brew)   error "  brew install python3" ;;
        esac
        exit 1
    fi

    # Auto-install paru (Arch only)
    if [[ "$PKG_MGR" == "pacman" ]] && ! command -v paru >/dev/null 2>&1; then
        info "Installing paru from AUR (non-interactive)..."

        # Check for base-devel
        if ! pacman -Qq base-devel >/dev/null 2>&1; then
            warn "base-devel not installed - paru installation may fail"
            warn "Install: sudo pacman -S base-devel"
        fi

        local temp_dir
        temp_dir=$(mktemp -d)

        if git clone https://aur.archlinux.org/paru.git "$temp_dir/paru" 2>/dev/null; then
            (cd "$temp_dir/paru" && makepkg -si --noconfirm) && success "Paru installed" || warn "Paru installation failed"
            rm -rf "$temp_dir"
        else
            warn "Failed to clone paru repo - AUR packages will be skipped"
        fi
    fi

    success "Prerequisites checked"
}

# ============================================================================
# MODULE DISCOVERY
# ============================================================================

# Discover modules by scanning for directories with deps.yaml
# Returns associative array: module_name -> directory_path
discover_modules() {
    declare -g -A DISCOVERED_MODULES

    info "Discovering modules..."

    local count=0
    while IFS= read -r -d '' deps_file; do
        local module_dir
        module_dir="$(dirname "$deps_file")"

        # Skip if not a directory
        [[ ! -d "$module_dir" ]] && continue

        # Module name = directory name
        local module_name
        module_name="$(basename "$module_dir")"

        # Store absolute path
        DISCOVERED_MODULES["$module_name"]="$module_dir"
        ((count++))
    done < <(find "$SCRIPT_DIR" -mindepth 2 -maxdepth 2 -name "deps.yaml" -print0 2>/dev/null)

    info "Discovered $count modules"

    if [[ $count -eq 0 ]]; then
        error "No modules discovered (no directories with deps.yaml found)"
        exit 1
    fi
}

# ============================================================================
# CONFIG.YAML PARSING
# ============================================================================

# Check if a name refers to a toolkit (returns 0 if yes, 1 if no).
is_toolkit() {
    local name="$1"
    local result
    result="$(yq -r ".toolkits[]? | select(.name == \"$name\") | .name" "$CONFIG_FILE" 2>/dev/null)"
    [[ -n "$result" ]]
}

# Get the list of module names for a toolkit.
# Returns newline-separated module names.
get_toolkit_modules() {
    local toolkit_name="$1"
    yq -r ".toolkits[]? | select(.name == \"$toolkit_name\") | .modules[]?" "$CONFIG_FILE" 2>/dev/null
}

# Find the machine index in config.yaml that matches the given hostname.
# Supports glob patterns (e.g., "codespaces-*") and case-insensitive matching.
# Prints the 0-based index, or returns 1 if no match.
find_machine_index() {
    local hostname="${1,,}"  # lowercase the actual hostname
    local machine_count
    machine_count="$(yq -r '.machines | length' "$CONFIG_FILE")"

    for i in $(seq 0 $((machine_count - 1))); do
        local pattern
        pattern="$(yq -r ".machines[$i].hostname" "$CONFIG_FILE")"
        pattern="${pattern,,}"  # lowercase the pattern too
        # Use bash glob matching: pattern may contain * or ?
        # shellcheck disable=SC2254
        case "$hostname" in
            $pattern)
                echo "$i"
                return 0
                ;;
        esac
    done

    return 1
}

# Get the list of module names assigned to the current machine.
# Returns newline-separated module names.
get_machine_modules() {
    local hostname="$1"
    local idx
    idx="$(find_machine_index "$hostname")" || return 1

    # Iterate over the modules array for this machine.
    # Each entry is either a plain string or an object with .name
    local count
    count="$(yq -r ".machines[$idx].modules | length" "$CONFIG_FILE")"

    for i in $(seq 0 $((count - 1))); do
        local entry_type
        entry_type="$(yq -r ".machines[$idx].modules[$i] | type" "$CONFIG_FILE")"

        if [[ "$entry_type" == "!!str" ]] || [[ "$entry_type" == "string" ]]; then
            yq -r ".machines[$idx].modules[$i]" "$CONFIG_FILE"
        else
            yq -r ".machines[$idx].modules[$i].name" "$CONFIG_FILE"
        fi
    done
}

# Expand toolkits and module references for a machine into a deduplicated list.
# Populates MODULE_TARGETS associative array with target overrides.
# Returns newline-separated module names.
expand_machine_modules() {
    local hostname="$1"
    local idx
    idx="$(find_machine_index "$hostname")" || return 1

    # Track seen modules to detect duplicates
    declare -A seen_modules

    # Clear MODULE_TARGETS for this expansion
    MODULE_TARGETS=()

    # Get the count of module entries for this machine
    local count
    count="$(yq -r ".machines[$idx].modules | length" "$CONFIG_FILE")"

    for i in $(seq 0 $((count - 1))); do
        local entry_type name target
        entry_type="$(yq -r ".machines[$idx].modules[$i] | type" "$CONFIG_FILE")"

        # Extract name and optional target
        if [[ "$entry_type" == "!!str" ]] || [[ "$entry_type" == "string" ]]; then
            name="$(yq -r ".machines[$idx].modules[$i]" "$CONFIG_FILE")"
            target=""
        else
            name="$(yq -r ".machines[$idx].modules[$i].name" "$CONFIG_FILE")"
            target="$(yq -r ".machines[$idx].modules[$i].target // \"\"" "$CONFIG_FILE")"
        fi

        # Check if this is a toolkit
        if is_toolkit "$name"; then
            # Expand toolkit to individual modules
            local toolkit_modules
            toolkit_modules="$(get_toolkit_modules "$name")"

            if [[ -z "$toolkit_modules" ]]; then
                warn "Toolkit '$name' is empty -- skipping"
                ERRORS+=("toolkit '$name' is empty")
                continue
            fi

            while IFS= read -r module_name; do
                [[ -z "$module_name" ]] && continue

                # Check if module exists in discovered modules
                if [[ -z "${DISCOVERED_MODULES[$module_name]+x}" ]]; then
                    warn "Module '$module_name' in toolkit '$name' not found (no directory with deps.yaml) -- skipping"
                    ERRORS+=("module '$module_name' from toolkit '$name' not found")
                    continue
                fi

                # Check for duplicates
                if [[ -n "${seen_modules[$module_name]+x}" ]]; then
                    warn "Module '$module_name' already included, skipping duplicate reference"
                    ERRORS+=("duplicate module '$module_name'")
                    continue
                fi

                seen_modules[$module_name]=1
                echo "$module_name"

                # Store target override if toolkit had one
                if [[ -n "$target" ]]; then
                    MODULE_TARGETS[$module_name]="$target"
                fi
            done <<< "$toolkit_modules"
        else
            # Regular module reference
            # Check if module exists in discovered modules
            if [[ -z "${DISCOVERED_MODULES[$name]+x}" ]]; then
                warn "Module '$name' not found (no directory with deps.yaml) -- skipping"
                ERRORS+=("module '$name' not found")
                continue
            fi

            # Check for duplicates
            if [[ -n "${seen_modules[$name]+x}" ]]; then
                warn "Module '$name' already included, skipping duplicate reference"
                ERRORS+=("duplicate module '$name'")
                continue
            fi

            seen_modules[$name]=1
            echo "$name"

            # Store target override if module had one
            if [[ -n "$target" ]]; then
                MODULE_TARGETS[$name]="$target"
            fi
        fi
    done
}

# Get the machine-level target override for a specific module (empty string if not set).
get_machine_module_target() {
    local hostname="$1"
    local module_name="$2"

    local idx
    idx="$(find_machine_index "$hostname")" || { echo ""; return 0; }

    local count
    count="$(yq -r ".machines[$idx].modules | length" "$CONFIG_FILE")"

    for i in $(seq 0 $((count - 1))); do
        local entry_type
        entry_type="$(yq -r ".machines[$idx].modules[$i] | type" "$CONFIG_FILE")"

        if [[ "$entry_type" != "!!str" ]] && [[ "$entry_type" != "string" ]]; then
            local name
            name="$(yq -r ".machines[$idx].modules[$i].name" "$CONFIG_FILE")"
            if [[ "$name" == "$module_name" ]]; then
                yq -r ".machines[$idx].modules[$i].target // \"\"" "$CONFIG_FILE"
                return 0
            fi
        fi
    done

    echo ""
}

# Resolve the final target directory for a module on a machine.
# Priority: MODULE_TARGETS (from expansion) > machine-level override > module-level default > $HOME
resolve_target() {
    local hostname="$1"
    local module_name="$2"

    # First check MODULE_TARGETS from expansion
    if [[ -n "${MODULE_TARGETS[$module_name]+x}" ]]; then
        local expansion_target="${MODULE_TARGETS[$module_name]}"
        if [[ -n "$expansion_target" ]]; then
            eval echo "$expansion_target"
            return
        fi
    fi

    # Then check machine-level override
    local machine_target
    machine_target="$(get_machine_module_target "$hostname" "$module_name")"

    if [[ -n "$machine_target" ]]; then
        eval echo "$machine_target"
        return
    fi

    # Default to $HOME
    echo "$HOME"
}

# ============================================================================
# DEPENDENCY COLLECTION: collect all deps from selected modules
# ============================================================================

# Collects all dependencies from all selected modules into global arrays
collect_all_dependencies() {
    local -a module_list=("$@")

    # Global arrays for collected dependencies
    declare -g -a ALL_NATIVE_PKGS=()
    declare -g -a ALL_AUR_PKGS=()
    declare -g -a ALL_CARGO_PKGS=()
    declare -g -a ALL_PIP_PKGS=()
    declare -g -a ALL_SCRIPTS=()
    declare -g -a ALL_REQUIRED_BINARIES=()

    local os_key
    os_key="$(get_deps_os_key "$PKG_MGR")"

    info "Collecting dependencies from ${#module_list[@]} modules..."

    local deps_files_found=0
    for module_name in "${module_list[@]}"; do
        if [[ -z "${DISCOVERED_MODULES[$module_name]+x}" ]]; then
            continue
        fi

        local module_path="${DISCOVERED_MODULES[$module_name]}"
        local deps_file="$module_path/deps.yaml"

        if [[ ! -f "$deps_file" ]]; then
            continue
        fi

        ((deps_files_found++))

        # Collect provides field for verification
        local provides
        provides="$(yq -r '.provides // empty' "$deps_file" 2>/dev/null)"
        if [[ -n "$provides" ]]; then
            # Handle both string and array formats
            if [[ "$provides" == "["* ]]; then
                # Array format
                while IFS= read -r binary; do
                    [[ -n "$binary" ]] && ALL_REQUIRED_BINARIES+=("$binary")
                done < <(yq -r '.provides[]? // empty' "$deps_file" 2>/dev/null)
            else
                # String format
                ALL_REQUIRED_BINARIES+=("$provides")
            fi
        fi

        # Parse packages for this OS
        if [[ -z "$os_key" ]]; then
            continue
        fi

        # Get count of package entries
        local pkg_count
        pkg_count="$(yq -r ".packages.${os_key} | length // 0" "$deps_file" 2>/dev/null)"

        for i in $(seq 0 $((pkg_count - 1))); do
            local entry_type
            entry_type="$(yq -r ".packages.${os_key}[$i] | type" "$deps_file" 2>/dev/null)"

            if [[ "$entry_type" == "!!str" ]] || [[ "$entry_type" == "string" ]]; then
                # String entry - parse prefix
                local pkg
                pkg="$(yq -r ".packages.${os_key}[$i]" "$deps_file" 2>/dev/null)"

                case "$pkg" in
                    aur:*)
                        ALL_AUR_PKGS+=("${pkg#aur:}")
                        ;;
                    cargo:*)
                        ALL_CARGO_PKGS+=("${pkg#cargo:}")
                        ;;
                    pip:*)
                        ALL_PIP_PKGS+=("${pkg#pip:}")
                        ;;
                    *)
                        ALL_NATIVE_PKGS+=("$pkg")
                        ;;
                esac
            else
                # Object entry - install script
                local run_cmd provides_binary
                run_cmd="$(yq -r ".packages.${os_key}[$i].run" "$deps_file" 2>/dev/null)"
                provides_binary="$(yq -r ".packages.${os_key}[$i].provides // \"\"" "$deps_file" 2>/dev/null)"

                ALL_SCRIPTS+=("$run_cmd|$provides_binary")

                if [[ -n "$provides_binary" ]]; then
                    ALL_REQUIRED_BINARIES+=("$provides_binary")
                fi
            fi
        done
    done

    info "Found $deps_files_found modules with deps.yaml"
    info "Collected: ${#ALL_NATIVE_PKGS[@]} native, ${#ALL_AUR_PKGS[@]} AUR, ${#ALL_CARGO_PKGS[@]} cargo, ${#ALL_PIP_PKGS[@]} pip, ${#ALL_SCRIPTS[@]} scripts"

    # Remove duplicates
    if [[ ${#ALL_NATIVE_PKGS[@]} -gt 0 ]]; then
        mapfile -t ALL_NATIVE_PKGS < <(printf '%s\n' "${ALL_NATIVE_PKGS[@]}" | sort -u)
    fi
    if [[ ${#ALL_AUR_PKGS[@]} -gt 0 ]]; then
        mapfile -t ALL_AUR_PKGS < <(printf '%s\n' "${ALL_AUR_PKGS[@]}" | sort -u)
    fi
    if [[ ${#ALL_CARGO_PKGS[@]} -gt 0 ]]; then
        mapfile -t ALL_CARGO_PKGS < <(printf '%s\n' "${ALL_CARGO_PKGS[@]}" | sort -u)
    fi
    if [[ ${#ALL_PIP_PKGS[@]} -gt 0 ]]; then
        mapfile -t ALL_PIP_PKGS < <(printf '%s\n' "${ALL_PIP_PKGS[@]}" | sort -u)
    fi
    if [[ ${#ALL_REQUIRED_BINARIES[@]} -gt 0 ]]; then
        mapfile -t ALL_REQUIRED_BINARIES < <(printf '%s\n' "${ALL_REQUIRED_BINARIES[@]}" | sort -u)
    fi
}

# Install all collected dependencies at once
install_all_dependencies() {
    echo ""
    info "${BOLD}Installing Dependencies${NC}"
    echo ""

    # Install native packages
    if [[ ${#ALL_NATIVE_PKGS[@]} -gt 0 ]]; then
        info "Native packages (${#ALL_NATIVE_PKGS[@]}): ${ALL_NATIVE_PKGS[*]}"
        if install_native_packages "$PKG_MGR" "${ALL_NATIVE_PKGS[@]}"; then
            PACKAGES_INSTALLED+=${#ALL_NATIVE_PKGS[@]}
        else
            ERRORS+=("some native packages failed")
        fi
    fi

    # Install AUR packages
    if [[ ${#ALL_AUR_PKGS[@]} -gt 0 ]]; then
        info "AUR packages (${#ALL_AUR_PKGS[@]}): ${ALL_AUR_PKGS[*]}"
        install_aur_packages "${ALL_AUR_PKGS[@]}"
    fi

    # Install cargo packages
    if [[ ${#ALL_CARGO_PKGS[@]} -gt 0 ]]; then
        info "Cargo packages (${#ALL_CARGO_PKGS[@]}): ${ALL_CARGO_PKGS[*]}"
        install_cargo_packages "${ALL_CARGO_PKGS[@]}"
    fi

    # Install pip packages
    if [[ ${#ALL_PIP_PKGS[@]} -gt 0 ]]; then
        info "Pip packages (${#ALL_PIP_PKGS[@]}): ${ALL_PIP_PKGS[*]}"
        install_pip_packages "${ALL_PIP_PKGS[@]}"
    fi

    # Run install scripts
    if [[ ${#ALL_SCRIPTS[@]} -gt 0 ]]; then
        info "Install scripts (${#ALL_SCRIPTS[@]})"
        for script_entry in "${ALL_SCRIPTS[@]}"; do
            local run_cmd="${script_entry%%|*}"
            local provides="${script_entry##*|}"

            # If 'provides' is set, skip if that binary already exists
            if [[ -n "$provides" ]] && command -v "$provides" >/dev/null 2>&1; then
                info "  Script skipped (${provides} already available)"
                continue
            fi

            if [[ "$DRY_RUN" == "true" ]]; then
                info "  [DRY-RUN] Would run script: $run_cmd"
                continue
            fi

            info "  Running: $run_cmd"
            if eval "$run_cmd"; then
                SCRIPTS_RUN+=1
            else
                warn "  Install script failed: $run_cmd"
                ERRORS+=("script failed: $run_cmd")
            fi
        done
    fi

    if [[ ${#ALL_NATIVE_PKGS[@]} -eq 0 && ${#ALL_AUR_PKGS[@]} -eq 0 && \
          ${#ALL_CARGO_PKGS[@]} -eq 0 && ${#ALL_PIP_PKGS[@]} -eq 0 && \
          ${#ALL_SCRIPTS[@]} -eq 0 ]]; then
        info "No dependencies to install"
    else
        success "Dependencies installed"
    fi
}

# Verify that all required binaries are available after installation.
# Returns 0 if all required binaries are available, 1 if any are missing.
verify_dependencies() {
    if [[ ${#ALL_REQUIRED_BINARIES[@]} -eq 0 ]]; then
        return 0
    fi

    echo ""
    info "${BOLD}Verifying Dependencies${NC}"
    echo ""

    local -a missing_binaries=()

    for binary in "${ALL_REQUIRED_BINARIES[@]}"; do
        if command -v "$binary" >/dev/null 2>&1; then
            success "  ✓ $binary"
        else
            error "  ✗ $binary (not found)"
            missing_binaries+=("$binary")
        fi
    done

    if [[ ${#missing_binaries[@]} -gt 0 ]]; then
        echo ""
        warn "Missing binaries (${#missing_binaries[@]}): ${missing_binaries[*]}"
        warn "Some dependencies may not be available yet."
        warn "Continuing with installation..."
        return 0
    fi

    success "All dependencies verified"
    return 0
}

# ============================================================================
# MODULE PROCESSING
# ============================================================================

process_module() {
    local module_name="$1"

    # Look up module in discovered modules
    if [[ -z "${DISCOVERED_MODULES[$module_name]+x}" ]]; then
        warn "Module '$module_name' not found -- skipping"
        ERRORS+=("module '$module_name' not found")
        return 0
    fi

    local module_abs_path="${DISCOVERED_MODULES[$module_name]}"
    if [[ ! -d "$module_abs_path" ]]; then
        warn "Module directory does not exist: $module_abs_path -- skipping"
        ERRORS+=("module dir missing: $module_abs_path")
        return 0
    fi

    # Resolve target directory
    local target
    target="$(resolve_target "$CURRENT_HOST" "$module_name")"

    echo ""
    info "${BOLD}[$module_name]${NC} -> $target"

    # --- Backup conflicting files ---
    backup_conflicts_for_module "$module_abs_path" "$target"

    # --- Stow ---
    mkdir -p "$target"

    if stow --restow --no-folding --verbose --dir="$SCRIPT_DIR" --target="$target" "$module_name" 2>&1; then
        success "  Stowed $module_name"
        MODULES_STOWED+=1
        STOWED_MODULES+=("$module_name")
    else
        error "  Failed to stow $module_name"
        ERRORS+=("stow failed for $module_name")
    fi
}

# ============================================================================
# SUMMARY
# ============================================================================

print_summary() {
    echo ""
    echo "============================================================"
    echo "                    Install Summary"
    echo "============================================================"
    echo ""

    if [[ $MODULES_STOWED -gt 0 ]]; then
        success "Modules stowed ($MODULES_STOWED): ${STOWED_MODULES[*]}"
    else
        warn "No modules were stowed"
    fi

    if [[ $PACKAGES_INSTALLED -gt 0 ]]; then
        info "Native packages processed: $PACKAGES_INSTALLED"
    fi

    if [[ $CARGO_INSTALLED -gt 0 ]]; then
        info "Cargo packages installed: $CARGO_INSTALLED"
    fi

    if [[ $PIP_INSTALLED -gt 0 ]]; then
        info "Pip packages installed: $PIP_INSTALLED"
    fi

    if [[ $SCRIPTS_RUN -gt 0 ]]; then
        info "Install scripts executed: $SCRIPTS_RUN"
    fi

    if [[ $FILES_BACKED_UP -gt 0 ]]; then
        info "Files backed up ($FILES_BACKED_UP) to: $BACKUP_DIR"
    fi

    if [[ ${#ERRORS[@]} -gt 0 ]]; then
        echo ""
        warn "Errors encountered (${#ERRORS[@]}):"
        for err in "${ERRORS[@]}"; do
            echo -e "  ${RED}-${NC} $err"
        done
    fi

    echo ""
    if [[ ${#ERRORS[@]} -eq 0 ]]; then
        success "Installation complete!"
    else
        warn "Installation complete with ${#ERRORS[@]} warning(s)."
    fi
    echo ""
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    echo ""
    echo "============================================================"
    echo "              Dotfiles Installer"
    echo "============================================================"
    echo ""

    # --- Detect environment ---
    local distro
    distro="$(detect_distro)"
    PKG_MGR="$(get_package_manager "$distro")"

    info "Distro:   $distro"
    info "Pkg mgr:  $PKG_MGR"

    if [[ "$PKG_MGR" == "unknown" ]]; then
        error "Could not detect a supported package manager."
        error "Supported: pacman (Arch), apt (Debian/Ubuntu), dnf (Fedora/RHEL), brew (macOS)"
        exit 1
    fi

    # --- Check core utilities and install if missing ---
    check_and_install_prerequisites

    # --- Now we can safely get the hostname ---
    CURRENT_HOST="$(hostname)"
    info "Host:     $CURRENT_HOST"

    # --- Validate config.yaml ---
    if [[ ! -f "$CONFIG_FILE" ]]; then
        error "Config file not found: $CONFIG_FILE"
        exit 1
    fi

    # --- Discover modules from directory structure ---
    discover_modules

    # --- Find modules for this machine ---
    local -a module_list=()
    while IFS= read -r mod; do
        [[ -n "$mod" ]] && module_list+=("$mod")
    done < <(expand_machine_modules "$CURRENT_HOST")

    if [[ ${#module_list[@]} -eq 0 ]]; then
        error "No modules found for hostname '$CURRENT_HOST'."
        error "Check that config.yaml has a machines[] entry with hostname: \"$CURRENT_HOST\""
        exit 1
    fi

    info "Modules to install (${#module_list[@]}): ${module_list[*]}"

    # --- Collect all dependencies from all modules ---
    collect_all_dependencies "${module_list[@]}"

    # --- Install all dependencies at once ---
    install_all_dependencies

    # --- Verify dependencies (non-blocking) ---
    verify_dependencies

    # --- Stow each module ---
    echo ""
    info "${BOLD}Stowing Modules${NC}"
    echo ""

    for module_name in "${module_list[@]}"; do
        process_module "$module_name"
    done

    # --- Print summary ---
    print_summary
}

# Global associative array for module target overrides from toolkit/module expansion
declare -A MODULE_TARGETS

# Export PKG_MGR so helpers can reference it
declare PKG_MGR=""

main "$@"
