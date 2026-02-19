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
CURRENT_HOST="$(hostname)"
BACKUP_DIR=""  # set lazily on first conflict
BACKUP_TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

# Counters for summary
declare -i MODULES_STOWED=0
declare -i PACKAGES_INSTALLED=0
declare -i CARGO_INSTALLED=0
declare -i PIP_INSTALLED=0
declare -i SCRIPTS_RUN=0
declare -i FILES_BACKED_UP=0
declare -a ERRORS=()
declare -a STOWED_MODULES=()

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

# Install native packages via the detected package manager.
# Accepts a list of package names. Skips if the list is empty.
install_native_packages() {
    local pkg_mgr="$1"
    shift
    local -a pkgs=("$@")

    if [[ ${#pkgs[@]} -eq 0 ]]; then
        return 0
    fi

    info "  Installing native packages: ${pkgs[*]}"

    case "$pkg_mgr" in
        pacman)
            sudo pacman -Sy --noconfirm --needed "${pkgs[@]}" || {
                warn "Some pacman packages may have failed"
                return 1
            }
            ;;
        apt)
            sudo apt-get update -qq
            sudo apt-get install -y -qq "${pkgs[@]}" || {
                warn "Some apt packages may not be available"
                return 1
            }
            ;;
        dnf)
            sudo dnf install -y -q "${pkgs[@]}" || {
                warn "Some dnf packages may not be available"
                return 1
            }
            ;;
        yum)
            sudo yum install -y -q "${pkgs[@]}" || {
                warn "Some yum packages may not be available"
                return 1
            }
            ;;
        brew)
            brew install "${pkgs[@]}" || {
                warn "Some brew packages may not be available"
                return 1
            }
            ;;
        *)
            error "Unsupported package manager: $pkg_mgr"
            error "Please install manually: ${pkgs[*]}"
            return 1
            ;;
    esac
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

    info "  Installing pip packages: ${pkgs[*]}"
    if $pip_cmd install --user "${pkgs[@]}"; then
        PIP_INSTALLED+=${#pkgs[@]}
    else
        warn "  Some pip packages may have failed"
        ERRORS+=("pip install failed for some packages")
    fi
}

# Run install scripts from deps.yaml. Each entry has:
#   - run: "command to execute"
#     provides: "binary-name"  (optional: skip if binary already exists)
run_install_scripts() {
    local deps_file="$1"

    local script_count
    script_count="$(yq -r '.script | length // 0' "$deps_file" 2>/dev/null)"

    if [[ "$script_count" -eq 0 ]]; then
        return 0
    fi

    for i in $(seq 0 $((script_count - 1))); do
        local run_cmd provides
        run_cmd="$(yq -r ".script[$i].run" "$deps_file")"
        provides="$(yq -r ".script[$i].provides // \"\"" "$deps_file")"

        # If 'provides' is set, skip if that binary already exists
        if [[ -n "$provides" ]] && command -v "$provides" >/dev/null 2>&1; then
            info "  Script skipped (${provides} already available)"
            continue
        fi

        info "  Running install script: $run_cmd"
        if eval "$run_cmd"; then
            SCRIPTS_RUN+=1
        else
            warn "  Install script failed: $run_cmd"
            ERRORS+=("script failed: $run_cmd")
        fi
    done
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
# SELF-BOOTSTRAP: install stow + yq if missing
# ============================================================================

self_bootstrap() {
    local -a missing=()

    for cmd in stow yq; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        return 0
    fi

    info "Missing required tools: ${missing[*]}"
    info "Installing via $PKG_MGR..."

    # On macOS, ensure Homebrew is available first
    if [[ "$PKG_MGR" == "brew" ]] && ! command -v brew >/dev/null 2>&1; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi

    install_native_packages "$PKG_MGR" "${missing[@]}"
    PACKAGES_INSTALLED+=${#missing[@]}

    # Verify they installed correctly
    for cmd in "${missing[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            error "'$cmd' still not found after install. Cannot continue."
            error "Please install '$cmd' manually and re-run."
            exit 1
        fi
    done

    success "Bootstrap tools installed"
}

# ============================================================================
# CONFIG.YAML PARSING
# ============================================================================

# Get the list of module names assigned to the current machine.
# Returns newline-separated module names.
get_machine_modules() {
    local hostname="$1"
    local machine_entry
    machine_entry="$(yq -r ".machines[] | select(.hostname == \"$hostname\")" "$CONFIG_FILE" 2>/dev/null)"

    if [[ -z "$machine_entry" ]]; then
        return 1
    fi

    # Iterate over the modules array for this machine.
    # Each entry is either a plain string or an object with .name
    local count
    count="$(yq -r ".machines[] | select(.hostname == \"$hostname\") | .modules | length" "$CONFIG_FILE")"

    for i in $(seq 0 $((count - 1))); do
        local entry_type
        entry_type="$(yq -r ".machines[] | select(.hostname == \"$hostname\") | .modules[$i] | type" "$CONFIG_FILE")"

        if [[ "$entry_type" == "!!str" ]] || [[ "$entry_type" == "string" ]]; then
            yq -r ".machines[] | select(.hostname == \"$hostname\") | .modules[$i]" "$CONFIG_FILE"
        else
            yq -r ".machines[] | select(.hostname == \"$hostname\") | .modules[$i].name" "$CONFIG_FILE"
        fi
    done
}

# Get the module path from the modules[] definition.
get_module_path() {
    local module_name="$1"
    yq -r ".modules[] | select(.name == \"$module_name\") | .path" "$CONFIG_FILE"
}

# Get the module-level default target (empty string if not set).
get_module_target() {
    local module_name="$1"
    yq -r ".modules[] | select(.name == \"$module_name\") | .target // \"\"" "$CONFIG_FILE"
}

# Get the machine-level target override for a specific module (empty string if not set).
get_machine_module_target() {
    local hostname="$1"
    local module_name="$2"

    local count
    count="$(yq -r ".machines[] | select(.hostname == \"$hostname\") | .modules | length" "$CONFIG_FILE")"

    for i in $(seq 0 $((count - 1))); do
        local entry_type
        entry_type="$(yq -r ".machines[] | select(.hostname == \"$hostname\") | .modules[$i] | type" "$CONFIG_FILE")"

        if [[ "$entry_type" != "!!str" ]] && [[ "$entry_type" != "string" ]]; then
            local name
            name="$(yq -r ".machines[] | select(.hostname == \"$hostname\") | .modules[$i].name" "$CONFIG_FILE")"
            if [[ "$name" == "$module_name" ]]; then
                yq -r ".machines[] | select(.hostname == \"$hostname\") | .modules[$i].target // \"\"" "$CONFIG_FILE"
                return 0
            fi
        fi
    done

    echo ""
}

# Resolve the final target directory for a module on a machine.
# Priority: machine-level override > module-level default > $HOME
resolve_target() {
    local hostname="$1"
    local module_name="$2"

    local machine_target
    machine_target="$(get_machine_module_target "$hostname" "$module_name")"

    if [[ -n "$machine_target" ]]; then
        eval echo "$machine_target"
        return
    fi

    local module_target
    module_target="$(get_module_target "$module_name")"

    if [[ -n "$module_target" ]]; then
        eval echo "$module_target"
        return
    fi

    echo "$HOME"
}

# ============================================================================
# MODULE PROCESSING
# ============================================================================

process_module() {
    local module_name="$1"

    # Look up module definition
    local module_rel_path
    module_rel_path="$(get_module_path "$module_name")"

    if [[ -z "$module_rel_path" || "$module_rel_path" == "null" ]]; then
        warn "Module '$module_name' not found in modules[] definitions -- skipping"
        ERRORS+=("module '$module_name' not defined in modules[]")
        return 0
    fi

    local module_abs_path="$SCRIPT_DIR/$module_rel_path"
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

    # --- deps.yaml handling ---
    local deps_file="$module_abs_path/deps.yaml"
    if [[ -f "$deps_file" ]]; then
        # Native packages
        local os_key
        os_key="$(get_deps_os_key "$PKG_MGR")"
        if [[ -n "$os_key" ]]; then
            local -a native_pkgs=()
            while IFS= read -r pkg; do
                [[ -n "$pkg" ]] && native_pkgs+=("$pkg")
            done < <(yq -r ".packages.${os_key}[]? // empty" "$deps_file" 2>/dev/null)

            if [[ ${#native_pkgs[@]} -gt 0 ]]; then
                if install_native_packages "$PKG_MGR" "${native_pkgs[@]}"; then
                    PACKAGES_INSTALLED+=${#native_pkgs[@]}
                else
                    ERRORS+=("native packages failed for $module_name")
                fi
            fi
        fi

        # Cargo packages
        local -a cargo_pkgs=()
        while IFS= read -r pkg; do
            [[ -n "$pkg" ]] && cargo_pkgs+=("$pkg")
        done < <(yq -r '.cargo[]? // empty' "$deps_file" 2>/dev/null)
        install_cargo_packages "${cargo_pkgs[@]}"

        # Pip packages
        local -a pip_pkgs=()
        while IFS= read -r pkg; do
            [[ -n "$pkg" ]] && pip_pkgs+=("$pkg")
        done < <(yq -r '.pip[]? // empty' "$deps_file" 2>/dev/null)
        install_pip_packages "${pip_pkgs[@]}"

        # Install scripts
        run_install_scripts "$deps_file"
    fi

    # --- Backup conflicting files ---
    backup_conflicts_for_module "$module_abs_path" "$target"

    # --- Stow ---
    mkdir -p "$target"

    if stow --restow --no-folding --dir="$SCRIPT_DIR" --target="$target" "$module_rel_path" 2>&1; then
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

    info "Host:     $CURRENT_HOST"
    info "Distro:   $distro"
    info "Pkg mgr:  $PKG_MGR"

    if [[ "$PKG_MGR" == "unknown" ]]; then
        error "Could not detect a supported package manager."
        error "Supported: pacman (Arch), apt (Debian/Ubuntu), dnf (Fedora/RHEL), brew (macOS)"
        exit 1
    fi

    # --- Self-bootstrap: ensure stow + yq ---
    self_bootstrap

    # --- Validate config.yaml ---
    if [[ ! -f "$CONFIG_FILE" ]]; then
        error "Config file not found: $CONFIG_FILE"
        exit 1
    fi

    # --- Find modules for this machine ---
    local -a module_list=()
    while IFS= read -r mod; do
        [[ -n "$mod" ]] && module_list+=("$mod")
    done < <(get_machine_modules "$CURRENT_HOST")

    if [[ ${#module_list[@]} -eq 0 ]]; then
        error "No modules found for hostname '$CURRENT_HOST'."
        error "Check that config.yaml has a machines[] entry with hostname: \"$CURRENT_HOST\""
        error "Available hostnames:"
        yq -r '.machines[].hostname' "$CONFIG_FILE" | while read -r h; do echo "  - $h"; done
        exit 1
    fi

    info "Modules to install (${#module_list[@]}): ${module_list[*]}"

    # --- Process each module ---
    for module_name in "${module_list[@]}"; do
        process_module "$module_name"
    done

    # --- Print summary ---
    print_summary
}

# Export PKG_MGR so helpers can reference it
declare PKG_MGR=""

main "$@"
