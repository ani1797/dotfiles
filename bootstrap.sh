#!/usr/bin/env bash
# bootstrap.sh - Fully automated dotfiles setup
# Works on Arch, Debian/Ubuntu, Fedora/RHEL, and GitHub Codespaces

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
    if [[ -f /etc/os-release ]]; then
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
        arch|manjaro|endeavouros)
            echo "pacman"
            ;;
        ubuntu|debian|pop|linuxmint)
            echo "apt"
            ;;
        fedora|rhel|centos|rocky|almalinux)
            echo "dnf"
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
            else
                echo "unknown"
            fi
            ;;
    esac
}

is_codespace() {
    [[ -n "${CODESPACES:-}" ]] || \
    [[ -n "${CODESPACE_NAME:-}" ]] || \
    [[ -f "/workspaces/.codespaces/.id" ]]
}

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

install_dependencies() {
    local pkg_mgr="$1"
    local -a missing_pkgs=()

    info "Checking for required dependencies..."

    # Check which packages are missing
    for cmd in stow yq zsh git curl; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            case "$cmd" in
                yq)
                    # yq package name varies by distro
                    case "$pkg_mgr" in
                        pacman) missing_pkgs+=("yq") ;;
                        apt) missing_pkgs+=("yq") ;;
                        dnf|yum) missing_pkgs+=("yq") ;;
                    esac
                    ;;
                *)
                    missing_pkgs+=("$cmd")
                    ;;
            esac
        fi
    done

    if [[ ${#missing_pkgs[@]} -eq 0 ]]; then
        success "All dependencies already installed"
        return 0
    fi

    info "Installing missing packages: ${missing_pkgs[*]}"

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
        *)
            error "Unsupported package manager: $pkg_mgr"
            error "Please install manually: ${missing_pkgs[*]}"
            return 1
            ;;
    esac

    success "Dependencies installed successfully"
}

backup_existing_configs() {
    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    local -a files_to_backup=(
        "$HOME/.zshrc"
        "$HOME/.config/zsh"
        "$HOME/.config/fish"
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
        "$HOME/.vimrc"
        "$HOME/.local/bin/configure-oh-my-zsh"
        "$HOME/.local/bin/configure-powerlevel10k"
        "$HOME/.local/bin/configure-zsh-plugins"
        "$HOME/.local/bin/configure-fzf"
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

install_zsh_tools() {
    info "Installing zsh tools..."

    # Oh-My-Zsh
    local omz_dir="$HOME/.oh-my-zsh"
    if [[ -d "$omz_dir" ]]; then
        info "Oh-My-Zsh already installed"
    else
        info "Installing Oh-My-Zsh..."
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        success "Oh-My-Zsh installed"
    fi

    # Powerlevel10k
    local p10k_dir="$HOME/.powerlevel10k"
    if [[ -d "$p10k_dir" ]]; then
        info "Powerlevel10k already installed"
    else
        info "Installing Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
        success "Powerlevel10k installed"
    fi

    # Zsh plugins
    local plugin_dir="$HOME/.zsh"
    mkdir -p "$plugin_dir"

    local -A plugins=(
        ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
        ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions.git"
        ["zsh-history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search.git"
    )

    for plugin_name in "${!plugins[@]}"; do
        local plugin_path="$plugin_dir/$plugin_name"
        if [[ -d "$plugin_path" ]]; then
            info "$plugin_name already installed"
        else
            info "Installing $plugin_name..."
            git clone --depth=1 "${plugins[$plugin_name]}" "$plugin_path"
            success "$plugin_name installed"
        fi
    done

    # FZF
    local fzf_dir="$HOME/.fzf"
    if [[ -d "$fzf_dir" ]]; then
        info "FZF already installed"
    else
        info "Installing FZF..."
        git clone --depth=1 https://github.com/junegunn/fzf.git "$fzf_dir"
        "$fzf_dir/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
        success "FZF installed"
    fi

    success "All zsh tools installed"
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
            "$HOME/.bashrc"
            "$HOME/.vimrc"
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
    if [[ -L "$HOME/.zshrc" ]]; then
        checks+=("✓ .zshrc symlink")
    else
        checks+=("✗ .zshrc symlink MISSING")
        all_ok=false
    fi

    if [[ -L "$HOME/.config/zsh" ]]; then
        checks+=("✓ .config/zsh symlink")
    else
        checks+=("✗ .config/zsh symlink MISSING")
        all_ok=false
    fi

    # Check tools
    local -a tools=(
        "$HOME/.oh-my-zsh:Oh-My-Zsh"
        "$HOME/.powerlevel10k:Powerlevel10k"
        "$HOME/.zsh/zsh-syntax-highlighting:zsh-syntax-highlighting"
        "$HOME/.zsh/zsh-autosuggestions:zsh-autosuggestions"
        "$HOME/.zsh/zsh-history-substring-search:zsh-history-substring-search"
        "$HOME/.fzf:FZF"
    )

    for tool in "${tools[@]}"; do
        IFS=':' read -r path name <<< "$tool"
        if [[ -d "$path" ]]; then
            checks+=("✓ $name")
        else
            checks+=("✗ $name MISSING")
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
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║                                                        ║"
    echo "║          Dotfiles Bootstrap Script                    ║"
    echo "║                                                        ║"
    echo "╚════════════════════════════════════════════════════════╝"
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

    if [[ "$pkg_mgr" == "unknown" ]]; then
        error "Could not detect package manager"
        error "Supported: pacman (Arch), apt (Debian/Ubuntu), dnf/yum (Fedora/RHEL)"
        exit 1
    fi

    echo ""

    # Install dependencies
    install_dependencies "$pkg_mgr"
    echo ""

    # Backup existing configs
    local backup_location
    backup_location="$(backup_existing_configs)"
    echo ""

    # Install zsh tools
    install_zsh_tools
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
        echo "╔════════════════════════════════════════════════════════╗"
        echo "║                                                        ║"
        echo "║          Bootstrap Complete! 🎉                       ║"
        echo "║                                                        ║"
        echo "╚════════════════════════════════════════════════════════╝"
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
        echo "  - Run: p10k configure (optional, to customize prompt)"
        echo "  - Enjoy your configured shell! 🚀"
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
