#!/usr/bin/env bash
# bootstrap.sh - Fully automated dotfiles setup
# Works on Arch, Debian/Ubuntu, Fedora/RHEL, macOS, and GitHub Codespaces

set -euo pipefail

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Error handler
trap 'error "Script failed at line $LINENO. Exit code: $?"' ERR

# ============================================================================
# DETECTION FUNCTIONS
# ============================================================================

detect_distro() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        echo "macos"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "${ID}"
    else
        warn "Could not detect distro from /etc/os-release"
        echo "unknown"
    fi
}

get_package_manager() {
    local distro="$1"
    case "$distro" in
        arch|manjaro|endeavouros|cachyos)
            echo "pacman"
            ;;
        ubuntu|debian|pop|linuxmint)
            echo "apt"
            ;;
        fedora|rhel|centos|rocky|almalinux)
            echo "dnf"
            ;;
        macos)
            echo "brew"
            ;;
        *)
            # Fallback to binary detection
            if command -v pacman >/dev/null 2>&1; then
                echo "pacman"
            elif command -v apt-get >/dev/null 2>&1; then
                echo "apt"
            elif command -v dnf >/dev/null 2>&1; then
                echo "dnf"
            elif command -v yum >/dev/null 2>&1; then
                echo "yum"
            elif command -v brew >/dev/null 2>&1; then
                echo "brew"
            else
                echo "unknown"
            fi
            ;;
    esac
}

# Map package manager to deps.yaml OS key
get_deps_os_key() {
    local pkg_mgr="$1"
    case "$pkg_mgr" in
        pacman) echo "arch" ;;
        apt)    echo "debian" ;;
        dnf|yum) echo "fedora" ;;
        brew)   echo "macos" ;;
        *)      echo "" ;;
    esac
}

is_codespace() {
    [[ -n "${CODESPACES:-}" ]] || \
    [[ -n "${CODESPACE_NAME:-}" ]] || \
    [[ -f "/workspaces/.codespaces/.id" ]]
}

is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }

is_wsl() {
    [[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]] || \
    [[ -n "${WSL_DISTRO_NAME:-}" ]]
}

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

install_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        info "Homebrew already installed"
        return 0
    fi

    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session
    if [[ -f /opt/homebrew/bin/brew ]]; then
        # Apple Silicon
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        # Intel Mac
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    success "Homebrew installed"
}

install_base_dependencies() {
    local pkg_mgr="$1"
    local -a missing_pkgs=()

    info "Checking for base dependencies..."

    # Check which packages are missing
    for cmd in stow yq zsh git curl; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_pkgs+=("$cmd")
        fi
    done

    if [[ ${#missing_pkgs[@]} -eq 0 ]]; then
        success "All base dependencies already installed"
        return 0
    fi

    info "Installing missing base packages: ${missing_pkgs[*]}"

    case "$pkg_mgr" in
        pacman)
            sudo pacman -Sy --noconfirm --needed "${missing_pkgs[@]}"
            ;;
        apt)
            sudo apt-get update -qq
            sudo apt-get install -y -qq "${missing_pkgs[@]}"
            ;;
        dnf)
            sudo dnf install -y -q "${missing_pkgs[@]}"
            ;;
        yum)
            sudo yum install -y -q "${missing_pkgs[@]}"
            ;;
        brew)
            brew install "${missing_pkgs[@]}"
            ;;
        *)
            error "Unsupported package manager: $pkg_mgr"
            error "Please install manually: ${missing_pkgs[*]}"
            return 1
            ;;
    esac

    success "Base dependencies installed successfully"
}

install_module_dependencies() {
    local pkg_mgr="$1"
    local os_key
    os_key="$(get_deps_os_key "$pkg_mgr")"

    if [[ -z "$os_key" ]]; then
        warn "Cannot determine OS key for package manager: $pkg_mgr"
        return 0
    fi

    info "Reading module dependencies from deps.yaml files..."

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local current_host
    current_host="$(hostname)"

    # Collect all packages from active modules' deps.yaml
    local -a all_packages=()
    local modules
    modules=$(yq -r '.modules[].name' "$script_dir/config.yaml")

    while read -r module; do
        # Check if this module applies to current host
        local host_match
        host_match=$(yq -r ".modules[] | select(.name == \"$module\") | .hosts[] | select(. == \"$current_host\" or .name == \"$current_host\")" "$script_dir/config.yaml" 2>/dev/null)

        if [[ -z "$host_match" ]]; then
            continue
        fi

        # Get module path
        local module_path
        module_path=$(yq -r ".modules[] | select(.name == \"$module\") | .path" "$script_dir/config.yaml")
        local deps_file="$script_dir/$module_path/deps.yaml"

        if [[ ! -f "$deps_file" ]]; then
            continue
        fi

        # Read packages for current OS
        local packages
        packages=$(yq -r ".packages.$os_key[]? // empty" "$deps_file" 2>/dev/null)
        if [[ -n "$packages" ]]; then
            while read -r pkg; do
                [[ -n "$pkg" ]] && all_packages+=("$pkg")
            done <<< "$packages"
        fi
    done <<< "$modules"

    if [[ ${#all_packages[@]} -eq 0 ]]; then
        info "No additional module packages to install"
        return 0
    fi

    # Deduplicate
    local -a unique_packages
    readarray -t unique_packages < <(printf '%s\n' "${all_packages[@]}" | sort -u)

    info "Module packages to install: ${unique_packages[*]}"

    case "$pkg_mgr" in
        pacman)
            sudo pacman -Sy --noconfirm --needed "${unique_packages[@]}"
            ;;
        apt)
            sudo apt-get install -y -qq "${unique_packages[@]}" 2>/dev/null || \
                warn "Some packages may not be available in apt repositories"
            ;;
        dnf)
            sudo dnf install -y -q "${unique_packages[@]}" 2>/dev/null || \
                warn "Some packages may not be available in dnf repositories"
            ;;
        brew)
            brew install "${unique_packages[@]}" 2>/dev/null || \
                warn "Some packages may not be available in Homebrew"
            ;;
    esac

    success "Module dependencies installed"
}

backup_existing_configs() {
    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    local -a files_to_backup=(
        "$HOME/.zshrc"
        "$HOME/.config/zsh"
        "$HOME/.config/fish"
        "$HOME/.config/bash"
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
        "$HOME/.vimrc"
        "$HOME/.config/nvim"
        "$HOME/.config/tmux"
        "$HOME/.tmux.conf"
        "$HOME/.config/starship.toml"
        "$HOME/.ssh/config"
    )

    local backed_up=false

    for file in "${files_to_backup[@]}"; do
        # Only backup real files, not symlinks (symlinks will be replaced by stow)
        if [[ -e "$file" && ! -L "$file" ]]; then
            if [[ ! "$backed_up" = true ]]; then
                info "Creating backup directory: $backup_dir"
                mkdir -p "$backup_dir"
                backed_up=true
            fi

            local rel_path="${file#$HOME/}"
            local backup_target="$backup_dir/$rel_path"
            mkdir -p "$(dirname "$backup_target")"

            if [[ -d "$file" ]]; then
                cp -r "$file" "$backup_target"
                info "Backed up directory: $rel_path"
            else
                cp "$file" "$backup_target"
                info "Backed up file: $rel_path"
            fi
        fi
    done

    if [[ "$backed_up" = true ]]; then
        success "Backup created at: $backup_dir"
        echo "$backup_dir"
    else
        info "No existing configs to backup"
        echo ""
    fi
}

install_starship() {
    if command -v starship >/dev/null 2>&1; then
        info "Starship already installed"
        return 0
    fi

    info "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    success "Starship installed"
}

install_zsh_plugins() {
    info "Installing zsh plugins..."

    # Zsh plugins (only if not available system-wide)
    local plugin_dir="$HOME/.zsh"
    mkdir -p "$plugin_dir"

    local -A plugins=(
        ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
        ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions.git"
        ["zsh-history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search.git"
    )

    for plugin_name in "${!plugins[@]}"; do
        # Skip if available system-wide
        if [[ -d "/usr/share/zsh/plugins/$plugin_name" ]] || \
           [[ -d "/usr/share/$plugin_name" ]]; then
            info "$plugin_name available system-wide, skipping user install"
            continue
        fi

        local plugin_path="$plugin_dir/$plugin_name"
        if [[ -d "$plugin_path" ]]; then
            info "$plugin_name already installed"
        else
            info "Installing $plugin_name..."
            git clone --depth=1 "${plugins[$plugin_name]}" "$plugin_path"
            success "$plugin_name installed"
        fi
    done

    # FZF (if not installed via package manager)
    if ! command -v fzf >/dev/null 2>&1; then
        local fzf_dir="$HOME/.fzf"
        if [[ -d "$fzf_dir" ]]; then
            info "FZF already installed"
        else
            info "Installing FZF..."
            git clone --depth=1 https://github.com/junegunn/fzf.git "$fzf_dir"
            "$fzf_dir/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
            success "FZF installed"
        fi
    fi

    success "All zsh plugins installed"
}

install_nerd_fonts() {
    info "Checking for Nerd Fonts..."

    # Check if any Nerd Font is installed
    if fc-list 2>/dev/null | grep -qi "nerd\|NF\|Nerd Font"; then
        info "Nerd Font already installed"
        return 0
    fi

    info "Installing JetBrainsMono Nerd Font..."
    local font_dir
    if is_macos; then
        font_dir="$HOME/Library/Fonts"
    else
        font_dir="$HOME/.local/share/fonts"
    fi
    mkdir -p "$font_dir"

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"

    if curl -fsSL "$font_url" -o "$tmp_dir/JetBrainsMono.tar.xz"; then
        tar -xf "$tmp_dir/JetBrainsMono.tar.xz" -C "$font_dir"
        if ! is_macos; then
            fc-cache -f "$font_dir" 2>/dev/null || true
        fi
        success "JetBrainsMono Nerd Font installed"
    else
        warn "Could not download Nerd Fonts (non-critical)"
    fi

    rm -rf "$tmp_dir"
}

deploy_dotfiles() {
    info "Deploying dotfiles with GNU Stow..."

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "$script_dir"

    # Run the existing install.sh script
    if ! ./install.sh; then
        warn "Stow encountered conflicts, attempting to resolve..."

        # Common conflicting files that need to be removed (already backed up)
        local -a conflicts=(
            "$HOME/.zshrc"
            "$HOME/.config/zsh"
            "$HOME/.config/fish"
            "$HOME/.config/bash"
            "$HOME/.bashrc"
            "$HOME/.vimrc"
            "$HOME/.config/starship.toml"
        )

        for file in "${conflicts[@]}"; do
            if [[ -e "$file" && ! -L "$file" ]]; then
                info "Removing conflicting file/dir: ${file#$HOME/}"
                rm -rf "$file"
            fi
        done

        # Retry install
        ./install.sh
    fi

    success "Dotfiles deployed successfully"
}

set_default_shell() {
    if is_codespace; then
        info "Running in GitHub Codespace - skipping shell change"
        info "Add 'exec zsh' to your .bashrc to auto-launch zsh"
        return 0
    fi

    if is_macos; then
        info "macOS detected - zsh is the default shell since Catalina"
        return 0
    fi

    local current_shell
    current_shell="$(basename "$SHELL")"

    if [[ "$current_shell" == "zsh" ]]; then
        info "Default shell already set to zsh"
        return 0
    fi

    info "Setting default shell to zsh..."

    # Ensure zsh is in /etc/shells
    local zsh_path
    zsh_path="$(command -v zsh)"
    if ! grep -q "^${zsh_path}$" /etc/shells 2>/dev/null; then
        info "Adding zsh to /etc/shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    # Change shell
    if sudo chsh -s "$zsh_path" "$USER"; then
        success "Default shell changed to zsh"
        info "You'll need to log out and back in for the change to take effect"
    else
        warn "Could not change default shell (non-critical)"
        info "You can manually run 'chsh -s $(command -v zsh)'"
    fi
}

verify_installation() {
    info "Verifying installation..."

    local -a checks=()
    local all_ok=true

    # Check symlinks
    local -a expected_symlinks=(
        "$HOME/.zshrc:.zshrc"
        "$HOME/.bashrc:.bashrc"
        "$HOME/.config/starship.toml:starship.toml"
    )

    for entry in "${expected_symlinks[@]}"; do
        IFS=':' read -r path label <<< "$entry"
        if [[ -L "$path" ]]; then
            checks+=("+ $label symlink")
        else
            checks+=("- $label symlink MISSING")
            all_ok=false
        fi
    done

    # Check directories
    local -a expected_dirs=(
        "$HOME/.config/zsh:.config/zsh"
        "$HOME/.config/bash:.config/bash"
    )

    for entry in "${expected_dirs[@]}"; do
        IFS=':' read -r path label <<< "$entry"
        if [[ -d "$path" ]]; then
            checks+=("+ $label directory")
        else
            checks+=("- $label directory MISSING")
            all_ok=false
        fi
    done

    # Check tools
    local -a tools=(
        "starship:Starship"
        "fzf:FZF"
        "stow:GNU Stow"
    )

    for tool in "${tools[@]}"; do
        IFS=':' read -r cmd name <<< "$tool"
        if command -v "$cmd" >/dev/null 2>&1; then
            checks+=("+ $name")
        else
            checks+=("- $name MISSING")
            all_ok=false
        fi
    done

    # Check zsh plugins
    local -a plugin_checks=(
        "zsh-syntax-highlighting"
        "zsh-autosuggestions"
        "zsh-history-substring-search"
    )

    for plugin in "${plugin_checks[@]}"; do
        if [[ -d "/usr/share/zsh/plugins/$plugin" ]] || \
           [[ -d "/usr/share/$plugin" ]] || \
           [[ -d "$HOME/.zsh/$plugin" ]]; then
            checks+=("+ $plugin")
        else
            checks+=("- $plugin MISSING")
            all_ok=false
        fi
    done

    # Print results
    echo ""
    for check in "${checks[@]}"; do
        echo "  $check"
    done
    echo ""

    # Test zsh loads
    info "Testing zsh configuration..."
    if zsh -c 'source ~/.zshrc' 2>/dev/null; then
        success "Zsh configuration loads successfully"
    else
        warn "Zsh configuration has errors (check manually)"
        all_ok=false
    fi

    if [[ "$all_ok" = true ]]; then
        success "All verification checks passed!"
        return 0
    else
        warn "Some verification checks failed"
        return 1
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    echo ""
    echo "============================================================"
    echo "                Dotfiles Bootstrap Script                    "
    echo "============================================================"
    echo ""

    # Detect environment
    info "Detecting environment..."
    local distro
    distro="$(detect_distro)"
    info "Detected distro: $distro"

    local pkg_mgr
    pkg_mgr="$(get_package_manager "$distro")"
    info "Package manager: $pkg_mgr"

    if is_codespace; then
        info "Running in GitHub Codespace"
    fi

    if is_macos; then
        info "Running on macOS"
    fi

    if is_wsl; then
        info "Running in WSL"
    fi

    if [[ "$pkg_mgr" == "unknown" ]]; then
        error "Could not detect package manager"
        error "Supported: pacman (Arch), apt (Debian/Ubuntu), dnf/yum (Fedora/RHEL), brew (macOS)"
        exit 1
    fi

    echo ""

    # Install Homebrew on macOS if needed
    if is_macos; then
        install_homebrew
        echo ""
    fi

    # Install base dependencies (stow, yq, zsh, git, curl)
    install_base_dependencies "$pkg_mgr"
    echo ""

    # Install module-specific dependencies from deps.yaml
    install_module_dependencies "$pkg_mgr"
    echo ""

    # Backup existing configs
    local backup_location
    backup_location="$(backup_existing_configs)"
    echo ""

    # Install Starship prompt
    install_starship
    echo ""

    # Install zsh plugins
    install_zsh_plugins
    echo ""

    # Install Nerd Fonts
    install_nerd_fonts
    echo ""

    # Deploy dotfiles
    deploy_dotfiles
    echo ""

    # Set default shell
    set_default_shell
    echo ""

    # Verify installation
    if verify_installation; then
        echo ""
        echo "============================================================"
        echo "                Bootstrap Complete!                          "
        echo "============================================================"
        echo ""

        if [[ -n "$backup_location" ]]; then
            info "Backup location: $backup_location"
            echo ""
        fi

        info "Next steps:"
        if is_codespace; then
            echo "  - Run: exec zsh"
        else
            echo "  - Log out and back in (or run: exec zsh)"
        fi
        echo "  - Run: configure-nvim (install Neovim plugins)"
        echo "  - Run: configure-tmux (install tmux plugins)"
        echo "  - Run: configure-ssh (set SSH permissions)"
        echo "  - Run: configure-git-machine <github-username> (configure git signing)"
        echo ""
    else
        echo ""
        warn "Bootstrap completed with warnings"
        warn "Please review the output above and fix any issues"
        echo ""
        exit 1
    fi
}

# Run main function
main "$@"
