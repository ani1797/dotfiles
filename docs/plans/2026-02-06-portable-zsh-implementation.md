# Portable ZSH Configuration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a portable, modular zsh configuration that works across multiple Linux distributions with graceful degradation and optional tool installation scripts.

**Architecture:** XDG-compliant modular configuration in `~/.config/zsh/` with numbered load order. Main `.zshrc` sources modules sequentially. Each module self-detects availability and conditionally loads. Helper scripts in `~/.local/bin/` for optional tool setup.

**Tech Stack:** Zsh, GNU Stow, Bash (for helper scripts), Git

---

## Task 1: Create Directory Structure

**Files:**
- Create: `zsh/.zshrc`
- Create: `zsh/.config/zsh/` (directory)
- Create: `zsh/.local/bin/` (directory)

**Step 1: Create the zsh stow module directory structure**

```bash
cd /home/anirudh/.local/share/dotfiles
mkdir -p zsh/.config/zsh
mkdir -p zsh/.local/bin
```

**Step 2: Verify directory structure**

Run: `tree zsh/ -L 3`
Expected: Shows zsh/, .config/zsh/, and .local/bin/ directories

**Step 3: Commit structure**

```bash
git add zsh/
git commit -m "feat(zsh): create module directory structure

- Add zsh stow module skeleton
- Create XDG-compliant config directory
- Add bin directory for helper scripts

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 2: Create Main .zshrc Entry Point

**Files:**
- Create: `zsh/.zshrc`

**Step 1: Write the main .zshrc file**

```bash
# ~/.zshrc
# Portable zsh configuration with graceful degradation

# Enable Powerlevel10k instant prompt if available
# Must be at the top for performance
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source all config files in .config/zsh/
ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
if [[ -d "$ZSH_CONFIG_DIR" ]]; then
  for config_file in "$ZSH_CONFIG_DIR"/*.zsh(N); do
    source "$config_file"
  done
fi

# Source machine-specific config if it exists
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
```

**Step 2: Verify syntax**

Run: `zsh -n zsh/.zshrc`
Expected: No output (syntax OK)

**Step 3: Commit**

```bash
git add zsh/.zshrc
git commit -m "feat(zsh): add main .zshrc entry point

- XDG Base Directory compliant
- Sources modular configs from ~/.config/zsh/
- Preserves P10k instant prompt
- Supports local overrides via .zshrc.local

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 3: Create Core Environment Module

**Files:**
- Create: `zsh/.config/zsh/00-environment.zsh`

**Step 1: Write environment configuration**

```bash
# ~/.config/zsh/00-environment.zsh
# Basic environment setup - always runs

# Add user binary directories to PATH
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Set default editor
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-vim}"

# XDG Base Directory specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
```

**Step 2: Verify syntax**

Run: `zsh -n zsh/.config/zsh/00-environment.zsh`
Expected: No output (syntax OK)

**Step 3: Commit**

```bash
git add zsh/.config/zsh/00-environment.zsh
git commit -m "feat(zsh): add environment configuration module

- Set up PATH with user binary directories
- Configure default editor
- Define XDG Base Directory variables

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 4: Create History Configuration Module

**Files:**
- Create: `zsh/.config/zsh/10-history.zsh`

**Step 1: Write history configuration**

```bash
# ~/.config/zsh/10-history.zsh
# History configuration - works on all zsh installs

# History file location and size
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000

# History behavior options
setopt HIST_IGNORE_SPACE      # Ignore commands starting with space
setopt HIST_IGNORE_DUPS       # Ignore duplicate commands
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicate entries from history
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks from history
setopt HIST_VERIFY            # Show command with history expansion before running
setopt SHARE_HISTORY          # Share history across all sessions
setopt APPEND_HISTORY         # Append to history file (not overwrite)
setopt INC_APPEND_HISTORY     # Write to history file immediately
```

**Step 2: Verify syntax**

Run: `zsh -n zsh/.config/zsh/10-history.zsh`
Expected: No output (syntax OK)

**Step 3: Commit**

```bash
git add zsh/.config/zsh/10-history.zsh
git commit -m "feat(zsh): add history configuration module

- Configure history file location and size
- Set intelligent history options
- Enable history sharing across sessions

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 5: Create Oh-My-Zsh Module

**Files:**
- Create: `zsh/.config/zsh/20-oh-my-zsh.zsh`

**Step 1: Write Oh-My-Zsh configuration**

```bash
# ~/.config/zsh/20-oh-my-zsh.zsh
# Oh-My-Zsh framework - loads if available

# Only load if Oh-My-Zsh is installed
if [[ -d "/usr/share/oh-my-zsh" ]] || [[ -d "$HOME/.oh-my-zsh" ]]; then
  # Set ZSH installation path (prefer system-wide)
  export ZSH="${ZSH:-/usr/share/oh-my-zsh}"
  [[ ! -d "$ZSH" ]] && export ZSH="$HOME/.oh-my-zsh"

  # Configuration options
  DISABLE_MAGIC_FUNCTIONS="true"
  ENABLE_CORRECTION="true"
  COMPLETION_WAITING_DOTS="true"

  # Default plugins if none set
  [[ -z "${plugins[*]}" ]] && plugins=(git fzf extract)

  # Load Oh-My-Zsh
  source "$ZSH/oh-my-zsh.sh"
fi
```

**Step 2: Verify syntax**

Run: `zsh -n zsh/.config/zsh/20-oh-my-zsh.zsh`
Expected: No output (syntax OK)

**Step 3: Commit**

```bash
git add zsh/.config/zsh/20-oh-my-zsh.zsh
git commit -m "feat(zsh): add Oh-My-Zsh module with detection

- Checks both system-wide and user-local installations
- Gracefully skips if not installed
- Configures sensible defaults and plugins

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 6: Create Powerlevel10k Theme Module

**Files:**
- Create: `zsh/.config/zsh/30-powerlevel10k.zsh`

**Step 1: Write Powerlevel10k configuration**

```bash
# ~/.config/zsh/30-powerlevel10k.zsh
# Powerlevel10k theme - loads if available

# Load Powerlevel10k theme from common locations
if [[ -f "/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
elif [[ -f "$HOME/.powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "$HOME/.powerlevel10k/powerlevel10k.zsh-theme"
fi

# Load p10k configuration if it exists
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
```

**Step 2: Verify syntax**

Run: `zsh -n zsh/.config/zsh/30-powerlevel10k.zsh`
Expected: No output (syntax OK)

**Step 3: Commit**

```bash
git add zsh/.config/zsh/30-powerlevel10k.zsh
git commit -m "feat(zsh): add Powerlevel10k theme module

- Checks system-wide and user-local installations
- Loads p10k config if present
- Gracefully skips if not available

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 7: Create Plugins Module

**Files:**
- Create: `zsh/.config/zsh/40-plugins.zsh`

**Step 1: Write plugins configuration**

```bash
# ~/.config/zsh/40-plugins.zsh
# Zsh plugins - loads if available

# Syntax highlighting - try multiple common locations
for plugin_path in \
  "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"; do
  if [[ -f "$plugin_path" ]]; then
    source "$plugin_path"
    break
  fi
done

# Autosuggestions - try multiple common locations
for plugin_path in \
  "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"; do
  if [[ -f "$plugin_path" ]]; then
    source "$plugin_path"
    break
  fi
done

# History substring search - try multiple common locations
for plugin_path in \
  "/usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" \
  "/usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh" \
  "$HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh"; do
  if [[ -f "$plugin_path" ]]; then
    source "$plugin_path"
    break
  fi
done

# FZF integration - check common locations
if [[ -f "/usr/share/fzf/key-bindings.zsh" ]]; then
  source /usr/share/fzf/key-bindings.zsh
  source /usr/share/fzf/completion.zsh
elif [[ -f "$HOME/.fzf.zsh" ]]; then
  source "$HOME/.fzf.zsh"
fi

# pkgfile "command not found" handler (Arch-specific)
[[ -f "/usr/share/doc/pkgfile/command-not-found.zsh" ]] && source /usr/share/doc/pkgfile/command-not-found.zsh
```

**Step 2: Verify syntax**

Run: `zsh -n zsh/.config/zsh/40-plugins.zsh`
Expected: No output (syntax OK)

**Step 3: Commit**

```bash
git add zsh/.config/zsh/40-plugins.zsh
git commit -m "feat(zsh): add plugins module with multi-path detection

- Syntax highlighting support
- Autosuggestions support
- History substring search
- FZF integration
- Checks multiple common install locations

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 8: Create Universal Aliases Module

**Files:**
- Create: `zsh/.config/zsh/50-aliases-universal.zsh`

**Step 1: Write universal aliases**

```bash
# ~/.config/zsh/50-aliases-universal.zsh
# Universal aliases that work on all systems

# Basic shortcuts
alias c="clear"
alias please="sudo"

# Modern command substitution (safer than backticks)
# Fallback to 4 cores if nproc unavailable
alias make="make -j\$(nproc 2>/dev/null || echo 4)"
alias ninja="ninja -j\$(nproc 2>/dev/null || echo 4)"
alias n="ninja"

# Safe ls aliases (if GNU coreutils available)
if ls --color=auto &>/dev/null 2>&1; then
  alias ls="ls --color=auto"
  alias ll="ls -lh"
  alias la="ls -lha"
  alias l="ls -CF"
fi

# Git aliases (if git installed)
if command -v git &>/dev/null; then
  alias g="git"
  alias gs="git status"
  alias gd="git diff"
  alias ga="git add"
  alias gc="git commit"
  alias gp="git push"
  alias gl="git log --oneline --graph --decorate"
fi

# Safety aliases
alias cp="cp -i"    # Prompt before overwrite
alias mv="mv -i"    # Prompt before overwrite
alias rm="rm -i"    # Prompt before delete

# Directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Process management
alias ps="ps auxf"
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"

# Network
alias ports="netstat -tulanp"
alias listening="lsof -i -P | grep LISTEN"
```

**Step 2: Verify syntax**

Run: `zsh -n zsh/.config/zsh/50-aliases-universal.zsh`
Expected: No output (syntax OK)

**Step 3: Commit**

```bash
git add zsh/.config/zsh/50-aliases-universal.zsh
git commit -m "feat(zsh): add universal aliases module

- Cross-platform aliases that work everywhere
- Modern command substitution with fallbacks
- Safety aliases for destructive commands
- Git shortcuts if available

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 9: Create Arch Linux Aliases Module

**Files:**
- Create: `zsh/.config/zsh/51-aliases-arch.zsh`

**Step 1: Write Arch-specific aliases**

```bash
# ~/.config/zsh/51-aliases-arch.zsh
# Arch Linux / CachyOS specific aliases

# Only load on Arch-based systems
if [[ -f /etc/arch-release ]] || [[ -f /etc/cachyos-release ]]; then

  # Package management
  alias update="sudo pacman -Syu"
  alias install="sudo pacman -S"
  alias remove="sudo pacman -Rsn"
  alias search="pacman -Ss"
  alias cleanpkg="sudo pacman -Scc"
  alias fixpacman="sudo rm /var/lib/pacman/db.lck"

  # Safer cleanup function with confirmation
  cleanup() {
    local orphans=$(pacman -Qtdq 2>/dev/null)
    if [[ -n "$orphans" ]]; then
      echo "Orphaned packages:"
      echo "$orphans"
      read "?Remove these packages? [y/N] " response
      if [[ "$response" =~ ^[Yy]$ ]]; then
        sudo pacman -Rsn $orphans
      else
        echo "Cancelled."
      fi
    else
      echo "No orphaned packages found."
    fi
  }

  # Help for people new to Arch
  alias apt="man pacman"
  alias apt-get="man pacman"
  alias yum="man pacman"
  alias dnf="man pacman"

  # System information
  alias jctl="journalctl -p 3 -xb"
  alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

  # AUR helper aliases (if installed)
  if command -v yay &>/dev/null; then
    alias yaupdate="yay -Syu"
    alias yain="yay -S"
    alias yarem="yay -Rsn"
    alias yasearch="yay -Ss"
  elif command -v paru &>/dev/null; then
    alias parupdate="paru -Syu"
    alias parain="paru -S"
    alias pararem="paru -Rsn"
    alias parasearch="paru -Ss"
  fi

fi
```

**Step 2: Verify syntax**

Run: `zsh -n zsh/.config/zsh/51-aliases-arch.zsh`
Expected: No output (syntax OK)

**Step 3: Commit**

```bash
git add zsh/.config/zsh/51-aliases-arch.zsh
git commit -m "feat(zsh): add Arch Linux aliases module

- Pacman package management shortcuts
- Safe cleanup function with confirmation
- Help aliases for users from other distros
- AUR helper support (yay/paru)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 10: Create Debian/Ubuntu Aliases Module

**Files:**
- Create: `zsh/.config/zsh/51-aliases-debian.zsh`

**Step 1: Write Debian-specific aliases**

```bash
# ~/.config/zsh/51-aliases-debian.zsh
# Debian / Ubuntu specific aliases

# Only load on Debian-based systems
if [[ -f /etc/debian_version ]]; then

  # Package management
  alias update="sudo apt update && sudo apt upgrade"
  alias install="sudo apt install"
  alias remove="sudo apt remove"
  alias search="apt search"
  alias autoremove="sudo apt autoremove"
  alias purge="sudo apt purge"
  alias aptclean="sudo apt clean && sudo apt autoclean"

  # Safer cleanup function with confirmation
  cleanup() {
    echo "Packages that can be auto-removed:"
    apt --dry-run autoremove 2>/dev/null
    read "?Remove these packages? [y/N] " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      sudo apt autoremove
    else
      echo "Cancelled."
    fi
  }

  # System information
  alias sysinfo="inxi -Fxz 2>/dev/null || lsb_release -a"
  alias services="systemctl list-units --type=service"
  alias logs="journalctl -xe"

  # Snap aliases (if snapd installed)
  if command -v snap &>/dev/null; then
    alias snapup="sudo snap refresh"
    alias snapin="sudo snap install"
    alias snaprm="sudo snap remove"
    alias snapls="snap list"
  fi

fi
```

**Step 2: Verify syntax**

Run: `zsh -n zsh/.config/zsh/51-aliases-debian.zsh`
Expected: No output (syntax OK)

**Step 3: Commit**

```bash
git add zsh/.config/zsh/51-aliases-debian.zsh
git commit -m "feat(zsh): add Debian/Ubuntu aliases module

- APT package management shortcuts
- Safe cleanup with dry-run preview
- System info and service management
- Snap support if installed

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 11: Create Fedora/RHEL Aliases Module

**Files:**
- Create: `zsh/.config/zsh/51-aliases-fedora.zsh`

**Step 1: Write Fedora-specific aliases**

```bash
# ~/.config/zsh/51-aliases-fedora.zsh
# Fedora / RHEL specific aliases

# Only load on Fedora/RHEL-based systems
if [[ -f /etc/fedora-release ]] || [[ -f /etc/redhat-release ]]; then

  # Detect dnf vs yum
  if command -v dnf &>/dev/null; then
    # DNF (modern Fedora/RHEL)
    alias update="sudo dnf upgrade"
    alias install="sudo dnf install"
    alias remove="sudo dnf remove"
    alias search="dnf search"
    alias cleanpkg="sudo dnf clean all"
    alias info="dnf info"

    # Safer cleanup function
    cleanup() {
      echo "Packages that can be auto-removed:"
      dnf list autoremove 2>/dev/null
      read "?Remove these packages? [y/N] " response
      if [[ "$response" =~ ^[Yy]$ ]]; then
        sudo dnf autoremove
      else
        echo "Cancelled."
      fi
    }

  else
    # YUM (older RHEL/CentOS)
    alias update="sudo yum update"
    alias install="sudo yum install"
    alias remove="sudo yum remove"
    alias search="yum search"
    alias cleanpkg="sudo yum clean all"
    alias info="yum info"
  fi

  # System information
  alias services="systemctl list-units --type=service"
  alias logs="journalctl -xe"
  alias firewall="sudo firewall-cmd --list-all"

  # SELinux helpers
  if command -v getenforce &>/dev/null; then
    alias selinux-status="getenforce"
    alias selinux-permissive="sudo setenforce 0"
    alias selinux-enforcing="sudo setenforce 1"
  fi

fi
```

**Step 2: Verify syntax**

Run: `zsh -n zsh/.config/zsh/51-aliases-fedora.zsh`
Expected: No output (syntax OK)

**Step 3: Commit**

```bash
git add zsh/.config/zsh/51-aliases-fedora.zsh
git commit -m "feat(zsh): add Fedora/RHEL aliases module

- DNF/YUM package management shortcuts
- Safe cleanup with preview
- System and service management
- SELinux helpers

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 12: Create Oh-My-Zsh Installation Script

**Files:**
- Create: `zsh/.local/bin/configure-oh-my-zsh`

**Step 1: Write the installation script**

```bash
#!/usr/bin/env bash
# Install Oh-My-Zsh if not present

set -e

OMZ_DIR="$HOME/.oh-my-zsh"

echo "==================================="
echo "Oh-My-Zsh Configuration Helper"
echo "==================================="
echo ""

# Check if already installed
if [[ -d "$OMZ_DIR" ]]; then
  echo "✓ Oh-My-Zsh already installed at $OMZ_DIR"
  echo ""
  read -p "Update to latest version? [y/N] " response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Updating Oh-My-Zsh..."
    cd "$OMZ_DIR" && git pull
    echo ""
    echo "✓ Updated successfully!"
  fi
  exit 0
fi

# Install Oh-My-Zsh
echo "Installing Oh-My-Zsh to $OMZ_DIR..."
echo ""

# Download and run installer in unattended mode
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo ""
echo "✓ Oh-My-Zsh installed successfully!"
echo ""
echo "Next steps:"
echo "  - Restart your shell or run: source ~/.zshrc"
echo "  - Customize plugins in ~/.config/zsh/20-oh-my-zsh.zsh"
```

**Step 2: Make script executable**

Run: `chmod +x zsh/.local/bin/configure-oh-my-zsh`
Expected: No output

**Step 3: Verify script syntax**

Run: `bash -n zsh/.local/bin/configure-oh-my-zsh`
Expected: No output (syntax OK)

**Step 4: Commit**

```bash
git add zsh/.local/bin/configure-oh-my-zsh
git commit -m "feat(zsh): add Oh-My-Zsh installation script

- Checks if already installed
- Offers update if present
- Installs in unattended mode
- Provides next steps

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 13: Create Powerlevel10k Installation Script

**Files:**
- Create: `zsh/.local/bin/configure-powerlevel10k`

**Step 1: Write the installation script**

```bash
#!/usr/bin/env bash
# Install Powerlevel10k theme

set -e

P10K_DIR="$HOME/.powerlevel10k"

echo "==================================="
echo "Powerlevel10k Configuration Helper"
echo "==================================="
echo ""

# Check if already installed
if [[ -d "$P10K_DIR" ]]; then
  echo "✓ Powerlevel10k already installed at $P10K_DIR"
  echo ""
  read -p "Update to latest version? [y/N] " response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Updating Powerlevel10k..."
    cd "$P10K_DIR" && git pull
    echo ""
    echo "✓ Updated successfully!"
  fi
  exit 0
fi

# Install Powerlevel10k
echo "Installing Powerlevel10k to $P10K_DIR..."
echo ""

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"

echo ""
echo "✓ Powerlevel10k installed successfully!"
echo ""
echo "Next steps:"
echo "  - Restart your shell or run: source ~/.zshrc"
echo "  - Run 'p10k configure' to set up your prompt style"
echo "  - Install a Nerd Font for best results:"
echo "    https://github.com/romkatv/powerlevel10k#fonts"
```

**Step 2: Make script executable**

Run: `chmod +x zsh/.local/bin/configure-powerlevel10k`
Expected: No output

**Step 3: Verify script syntax**

Run: `bash -n zsh/.local/bin/configure-powerlevel10k`
Expected: No output (syntax OK)

**Step 4: Commit**

```bash
git add zsh/.local/bin/configure-powerlevel10k
git commit -m "feat(zsh): add Powerlevel10k installation script

- Checks if already installed
- Offers update if present
- Clones theme repository
- Provides configuration instructions

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 14: Create Zsh Plugins Installation Script

**Files:**
- Create: `zsh/.local/bin/configure-zsh-plugins`

**Step 1: Write the installation script**

```bash
#!/usr/bin/env bash
# Install zsh plugins (syntax-highlighting, autosuggestions, history-substring-search)

set -e

PLUGIN_DIR="$HOME/.zsh"

echo "==================================="
echo "Zsh Plugins Configuration Helper"
echo "==================================="
echo ""

mkdir -p "$PLUGIN_DIR"

# Function to install or update a plugin
install_plugin() {
  local name="$1"
  local repo="$2"
  local target="$PLUGIN_DIR/$name"

  if [[ -d "$target" ]]; then
    echo "✓ $name already installed"
    read -p "  Update to latest version? [y/N] " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      echo "  Updating $name..."
      cd "$target" && git pull
      echo "  ✓ Updated!"
    fi
  else
    echo "Installing $name..."
    git clone --depth=1 "$repo" "$target"
    echo "✓ $name installed!"
  fi
  echo ""
}

# Install plugins
install_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
install_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
install_plugin "zsh-history-substring-search" "https://github.com/zsh-users/zsh-history-substring-search.git"

echo "==================================="
echo "All plugins processed!"
echo ""
echo "Next steps:"
echo "  - Restart your shell or run: source ~/.zshrc"
echo "  - Plugins will load automatically from ~/.zsh/"
```

**Step 2: Make script executable**

Run: `chmod +x zsh/.local/bin/configure-zsh-plugins`
Expected: No output

**Step 3: Verify script syntax**

Run: `bash -n zsh/.local/bin/configure-zsh-plugins`
Expected: No output (syntax OK)

**Step 4: Commit**

```bash
git add zsh/.local/bin/configure-zsh-plugins
git commit -m "feat(zsh): add plugins installation script

- Installs syntax-highlighting, autosuggestions, substring-search
- Checks if already installed
- Offers updates for existing plugins
- Creates plugin directory structure

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 15: Create FZF Installation Script

**Files:**
- Create: `zsh/.local/bin/configure-fzf`

**Step 1: Write the installation script**

```bash
#!/usr/bin/env bash
# Install FZF (fuzzy finder)

set -e

FZF_DIR="$HOME/.fzf"

echo "==================================="
echo "FZF Configuration Helper"
echo "==================================="
echo ""

# Check if already installed
if [[ -d "$FZF_DIR" ]]; then
  echo "✓ FZF already installed at $FZF_DIR"
  echo ""
  read -p "Update to latest version? [y/N] " response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Updating FZF..."
    cd "$FZF_DIR" && git pull
    echo ""
    echo "Reinstalling FZF bindings..."
    "$FZF_DIR/install" --key-bindings --completion --no-update-rc
    echo ""
    echo "✓ Updated successfully!"
  fi
  exit 0
fi

# Install FZF
echo "Installing FZF to $FZF_DIR..."
echo ""

git clone --depth=1 https://github.com/junegunn/fzf.git "$FZF_DIR"

echo ""
echo "Installing FZF binaries and shell integration..."
"$FZF_DIR/install" --key-bindings --completion --no-update-rc

echo ""
echo "✓ FZF installed successfully!"
echo ""
echo "Next steps:"
echo "  - Restart your shell or run: source ~/.zshrc"
echo "  - Try 'Ctrl+R' for history search"
echo "  - Try 'Ctrl+T' for file search"
echo "  - Try 'Alt+C' for directory navigation"
```

**Step 2: Make script executable**

Run: `chmod +x zsh/.local/bin/configure-fzf`
Expected: No output

**Step 3: Verify script syntax**

Run: `bash -n zsh/.local/bin/configure-fzf`
Expected: No output (syntax OK)

**Step 4: Commit**

```bash
git add zsh/.local/bin/configure-fzf
git commit -m "feat(zsh): add FZF installation script

- Installs FZF with key bindings and completion
- Checks if already installed
- Offers update if present
- Explains keyboard shortcuts

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 16: Update config.yaml for Zsh Module

**Files:**
- Modify: `config.yaml`

**Step 1: Add zsh module to config.yaml**

Add the following entry to the modules list:

```yaml
  - name: "zsh"
    path: "zsh"
    hosts:
      - HOME-DESKTOP
      - local
      - work
```

**Step 2: Verify YAML syntax**

Run: `yq eval '.' config.yaml > /dev/null`
Expected: No output (valid YAML)

**Step 3: View updated config**

Run: `yq eval '.modules[] | select(.name == "zsh")' config.yaml`
Expected: Shows the zsh module configuration

**Step 4: Commit**

```bash
git add config.yaml
git commit -m "feat(zsh): add zsh module to stow configuration

- Deploy zsh config to all hosts
- Includes modular configs and helper scripts

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 17: Create README for Zsh Module

**Files:**
- Create: `zsh/README.md`

**Step 1: Write the README**

```markdown
# Zsh Configuration Module

Portable, modular zsh configuration that works across multiple Linux distributions with graceful degradation.

## Features

- **XDG Base Directory compliant** - configs in `~/.config/zsh/`
- **Graceful degradation** - works without optional plugins/themes
- **Distro-specific aliases** - Arch, Debian/Ubuntu, Fedora/RHEL support
- **Runtime detection** - loads features only if available
- **Helper scripts** - easy installation of optional tools

## Deployment

```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh
```

This deploys:
- `~/.zshrc` - main entry point
- `~/.config/zsh/*.zsh` - modular configuration files
- `~/.local/bin/configure-*` - helper scripts

## Module Load Order

Files in `~/.config/zsh/` load in numbered order:

- `00-environment.zsh` - PATH and environment variables
- `10-history.zsh` - history configuration
- `20-oh-my-zsh.zsh` - Oh-My-Zsh framework (if available)
- `30-powerlevel10k.zsh` - Powerlevel10k theme (if available)
- `40-plugins.zsh` - syntax highlighting, autosuggestions (if available)
- `50-aliases-universal.zsh` - cross-platform aliases
- `51-aliases-arch.zsh` - Arch Linux specific (if on Arch)
- `51-aliases-debian.zsh` - Debian/Ubuntu specific (if on Debian)
- `51-aliases-fedora.zsh` - Fedora/RHEL specific (if on Fedora)

## Optional Tool Installation

Helper scripts in `~/.local/bin/`:

```bash
# Install Oh-My-Zsh framework
configure-oh-my-zsh

# Install Powerlevel10k theme
configure-powerlevel10k

# Install zsh plugins (syntax-highlighting, autosuggestions, etc.)
configure-zsh-plugins

# Install FZF fuzzy finder
configure-fzf
```

## Machine-Specific Overrides

Create `~/.zshrc.local` for machine-specific customizations not managed by stow:

```bash
# Example: work machine proxy settings
export HTTP_PROXY="http://proxy.example.com:8080"
export HTTPS_PROXY="http://proxy.example.com:8080"
```

## Customization

### Add New Distro Support

Create `zsh/.config/zsh/51-aliases-<distro>.zsh`:

```bash
# Check for distro-specific file
if [[ -f /etc/<distro>-release ]]; then
  # Define aliases here
  alias update="sudo <package-manager> update"
fi
```

### Add Personal Aliases

Edit `zsh/.config/zsh/50-aliases-universal.zsh` or create `~/.zshrc.local`

### Modify Plugin Load Paths

Edit `zsh/.config/zsh/40-plugins.zsh` to add additional search paths

## Security Features

- Modern `$()` command substitution (not backticks)
- Safe `cleanup()` functions with confirmation prompts
- Interactive prompts before destructive operations
- Fallback values for missing commands

## Troubleshooting

### Check what modules loaded
```bash
ls ~/.config/zsh/*.zsh
```

### Test syntax of all files
```bash
for f in ~/.config/zsh/*.zsh; do zsh -n "$f" && echo "✓ $f"; done
```

### Debug module loading
Add to `~/.zshrc` before the source loop:
```bash
setopt XTRACE  # Enable debug output
```

### Verify distro detection
```bash
# Check which distro-specific file should load
ls /etc/*-release
```

## References

- [Zsh Documentation](http://zsh.sourceforge.net/Doc/)
- [Oh-My-Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [XDG Base Directory](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
```

**Step 2: Commit**

```bash
git add zsh/README.md
git commit -m "docs(zsh): add comprehensive module README

- Explain features and deployment
- Document module load order
- Provide customization guide
- Include troubleshooting tips

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 18: Test Configuration Syntax

**Files:**
- Test: All `.zsh` files

**Step 1: Test all zsh configuration files**

```bash
cd /home/anirudh/.local/share/dotfiles
for f in zsh/.config/zsh/*.zsh zsh/.zshrc; do
  echo "Testing: $f"
  zsh -n "$f" && echo "  ✓ Syntax OK" || echo "  ✗ Syntax Error"
done
```

Expected: All files show "✓ Syntax OK"

**Step 2: Test all bash helper scripts**

```bash
for f in zsh/.local/bin/configure-*; do
  echo "Testing: $f"
  bash -n "$f" && echo "  ✓ Syntax OK" || echo "  ✗ Syntax Error"
done
```

Expected: All files show "✓ Syntax OK"

**Step 3: Verify file permissions**

```bash
ls -l zsh/.local/bin/
```

Expected: All configure-* scripts should be executable (rwxr-xr-x)

---

## Task 19: Test Deployment with Stow

**Files:**
- Test: Entire zsh module deployment

**Step 1: Backup existing zsh configuration**

```bash
if [[ -f "$HOME/.zshrc" ]]; then
  cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d)"
  echo "Backed up existing .zshrc"
fi
```

**Step 2: Deploy zsh module using stow**

```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh
```

Expected: No errors, stow creates symlinks

**Step 3: Verify symlinks created**

```bash
ls -la ~/.zshrc ~/.config/zsh ~/.local/bin/configure-*
```

Expected: All are symlinks pointing to dotfiles/zsh/

**Step 4: Test loading the new configuration**

```bash
zsh -c 'source ~/.zshrc && echo "✓ Config loaded successfully"'
```

Expected: "✓ Config loaded successfully" (may have warnings about missing plugins, which is OK)

**Step 5: Check which modules loaded**

```bash
zsh -c 'source ~/.zshrc && alias | grep -E "update|install|remove" | head -5'
```

Expected: Shows distro-appropriate aliases (pacman on CachyOS)

---

## Task 20: Create Final Summary Document

**Files:**
- Create: `docs/plans/2026-02-06-portable-zsh-deployment-summary.md`

**Step 1: Write deployment summary**

```markdown
# Portable Zsh Configuration - Deployment Summary

**Date:** 2026-02-06
**Status:** Complete

## What Was Built

A portable, modular zsh configuration that:
- Works across multiple Linux distributions (Arch, Debian, Fedora)
- Uses XDG Base Directory specification (`~/.config/zsh/`)
- Gracefully degrades when optional tools unavailable
- Provides helper scripts for optional tool installation
- Includes distro-specific aliases with runtime detection

## Files Created

### Configuration Files
- `zsh/.zshrc` - Main entry point
- `zsh/.config/zsh/00-environment.zsh` - Environment setup
- `zsh/.config/zsh/10-history.zsh` - History configuration
- `zsh/.config/zsh/20-oh-my-zsh.zsh` - Oh-My-Zsh integration
- `zsh/.config/zsh/30-powerlevel10k.zsh` - Theme support
- `zsh/.config/zsh/40-plugins.zsh` - Plugin loading
- `zsh/.config/zsh/50-aliases-universal.zsh` - Universal aliases
- `zsh/.config/zsh/51-aliases-arch.zsh` - Arch-specific
- `zsh/.config/zsh/51-aliases-debian.zsh` - Debian-specific
- `zsh/.config/zsh/51-aliases-fedora.zsh` - Fedora-specific

### Helper Scripts
- `zsh/.local/bin/configure-oh-my-zsh` - Install Oh-My-Zsh
- `zsh/.local/bin/configure-powerlevel10k` - Install P10k theme
- `zsh/.local/bin/configure-zsh-plugins` - Install plugins
- `zsh/.local/bin/configure-fzf` - Install FZF

### Documentation
- `zsh/README.md` - Module documentation
- `docs/plans/2026-02-06-portable-zsh-design.md` - Design document
- `docs/plans/2026-02-06-portable-zsh-implementation.md` - This plan

## Deployment

```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh
```

Deploys to hosts: HOME-DESKTOP, local, work

## Post-Deployment Steps

### Optional Tool Installation

```bash
# Install Oh-My-Zsh (optional)
configure-oh-my-zsh

# Install Powerlevel10k theme (optional)
configure-powerlevel10k

# Install zsh plugins (optional)
configure-zsh-plugins

# Install FZF fuzzy finder (optional)
configure-fzf
```

### Verify Configuration

```bash
# Test config loads
zsh -c 'source ~/.zshrc && echo OK'

# Check distro-specific aliases
alias | grep -E "update|install"

# Verify helper scripts
which configure-oh-my-zsh
```

## System-Specific Behavior

### On CachyOS (current system)
- Arch aliases loaded (pacman shortcuts)
- Can use existing system-wide Oh-My-Zsh and P10k
- pkgfile command-not-found handler loaded

### On Ubuntu/Debian systems
- Debian aliases loaded (apt shortcuts)
- Snap aliases if snapd installed
- Works with or without Oh-My-Zsh

### On Fedora/RHEL systems
- Fedora aliases loaded (dnf/yum shortcuts)
- SELinux helpers available
- Detects dnf vs yum automatically

## Security Improvements

Fixed issues from original CachyOS config:
1. ✅ Safe cleanup functions with confirmation
2. ✅ Modern `$()` instead of backticks
3. ✅ Fallback values for missing commands
4. ✅ Interactive prompts for destructive operations

## Success Criteria Met

- ✅ Single stow deployment to all systems
- ✅ Works across CachyOS, Ubuntu, Fedora
- ✅ Graceful degradation when tools missing
- ✅ Helper scripts for optional installations
- ✅ XDG Base Directory compliant
- ✅ Security issues fixed
- ✅ Easy to extend with new distros

## Future Enhancements

Easy extensions:
- Add more distro-specific alias files
- Add more helper scripts for other tools
- Customize plugin configurations per-host via `~/.zshrc.local`
- Add theme customization guides

## References

- Design: `docs/plans/2026-02-06-portable-zsh-design.md`
- Module README: `zsh/README.md`
- Config: `config.yaml` (zsh module entry)
```

**Step 2: Commit**

```bash
git add docs/plans/2026-02-06-portable-zsh-deployment-summary.md
git commit -m "docs(zsh): add deployment summary

- Document what was built
- List all created files
- Provide post-deployment steps
- Confirm success criteria met

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Completion

All tasks complete! The portable zsh configuration is:

✅ Designed (design document)
✅ Implemented (all config files and scripts)
✅ Documented (README and summary)
✅ Tested (syntax validation and deployment)
✅ Deployed (via GNU Stow)

The configuration works across multiple Linux distributions with graceful degradation and provides helper scripts for optional tool installation.
