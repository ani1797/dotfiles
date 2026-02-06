# Portable ZSH Configuration Design

**Date:** 2026-02-06
**Status:** Approved
**Target Systems:** HOME-DESKTOP, local, work (mixed Linux distributions)

## Overview

Design a portable zsh configuration that works across multiple Linux distributions (CachyOS, Arch, Ubuntu, Fedora, etc.) with graceful degradation. The configuration uses runtime detection to conditionally load features based on what's available, rather than requiring manual per-system configuration.

## Requirements

1. **Portability**: Single configuration deployed to all systems via GNU Stow
2. **Graceful Degradation**: Work without fancy plugins/themes if unavailable
3. **Optional Tool Setup**: Include helper scripts to install Oh-My-Zsh, Powerlevel10k, plugins, etc.
4. **Distro-Specific Features**: Load distro-appropriate aliases (pacman, apt, dnf) based on system detection
5. **XDG Compliance**: Use `~/.config/zsh/` for modular configuration files
6. **Security**: Fix unsafe patterns from original CachyOS config (command substitution, cleanup aliases)

## Architecture

### Approach: Smart Detection Layer

- Main `.zshrc` sources files from `~/.config/zsh/` in numbered order
- Each module self-detects if it should load (checks for binaries, distros, paths)
- Failed detections are silent - module simply doesn't activate
- All files deployed to all systems; conditional execution happens at runtime
- Helper scripts in `~/.local/bin/configure-*` for optional tool installation

### Directory Structure

```
dotfiles/zsh/
├── .zshrc                          # Main entry point
├── .config/
│   └── zsh/
│       ├── 00-environment.zsh      # PATH, environment variables
│       ├── 10-history.zsh          # History configuration
│       ├── 20-oh-my-zsh.zsh        # Oh-My-Zsh setup (if available)
│       ├── 30-powerlevel10k.zsh    # P10k theme (if available)
│       ├── 40-plugins.zsh          # Syntax highlighting, autosuggestions
│       ├── 50-aliases-universal.zsh # Cross-platform aliases
│       ├── 51-aliases-arch.zsh     # Arch/CachyOS specific
│       ├── 51-aliases-debian.zsh   # Debian/Ubuntu specific
│       ├── 51-aliases-fedora.zsh   # Fedora/RHEL specific
│       └── 99-local.zsh            # Machine-specific overrides (optional)
└── .local/
    └── bin/
        ├── configure-oh-my-zsh
        ├── configure-powerlevel10k
        ├── configure-zsh-plugins
        └── configure-fzf
```

**Numbered Prefixes:**
- `00-09`: Core environment setup (always runs)
- `10-19`: Shell behavior configuration (always runs)
- `20-49`: Optional frameworks/plugins (conditional)
- `50-59`: Aliases and shortcuts (universal + conditional)
- `99`: Local overrides (optional, not in stow)

## Component Details

### Main Entry Point: .zshrc

```bash
# ~/.zshrc
# Portable zsh configuration with graceful degradation

# Enable Powerlevel10k instant prompt if available
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

**Features:**
- P10k instant prompt preserved for performance
- XDG Base Directory specification compliant
- Glob pattern `(N)` returns empty if no matches
- Load order guaranteed by numbered filenames
- Local overrides via `.zshrc.local` (not in stow)

### Core Modules (Always Load)

#### 00-environment.zsh
```bash
# Basic environment setup - always runs
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-vim}"
```

#### 10-history.zsh
```bash
# History configuration - works on all zsh installs
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000
setopt HIST_IGNORE_SPACE      # Ignore commands starting with space
setopt HIST_IGNORE_DUPS       # Ignore duplicate commands
setopt SHARE_HISTORY          # Share history across sessions
```

### Optional Framework Modules

#### 20-oh-my-zsh.zsh
```bash
# Only load if Oh-My-Zsh is installed
if [[ -d "/usr/share/oh-my-zsh" ]] || [[ -d "$HOME/.oh-my-zsh" ]]; then
  export ZSH="${ZSH:-/usr/share/oh-my-zsh}"
  [[ ! -d "$ZSH" ]] && export ZSH="$HOME/.oh-my-zsh"

  DISABLE_MAGIC_FUNCTIONS="true"
  ENABLE_CORRECTION="true"
  COMPLETION_WAITING_DOTS="true"

  [[ -z "${plugins[*]}" ]] && plugins=(git fzf extract)
  source "$ZSH/oh-my-zsh.sh"
fi
```

Checks both system-wide (`/usr/share`) and user-local (`~/.oh-my-zsh`) installations.

#### 30-powerlevel10k.zsh
```bash
# Load Powerlevel10k if available
if [[ -f "/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
elif [[ -f "$HOME/.powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "$HOME/.powerlevel10k/powerlevel10k.zsh-theme"
fi

# Load p10k config if it exists
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
```

#### 40-plugins.zsh
```bash
# Syntax highlighting - try multiple locations
for plugin_path in \
  "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"; do
  if [[ -f "$plugin_path" ]]; then
    source "$plugin_path"
    break
  fi
done

# Autosuggestions - try multiple locations
for plugin_path in \
  "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"; do
  if [[ -f "$plugin_path" ]]; then
    source "$plugin_path"
    break
  fi
done

# History substring search
for plugin_path in \
  "/usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" \
  "/usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh" \
  "$HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh"; do
  if [[ -f "$plugin_path" ]]; then
    source "$plugin_path"
    break
  fi
done

# FZF integration
[[ -f "/usr/share/fzf/key-bindings.zsh" ]] && source /usr/share/fzf/key-bindings.zsh
[[ -f "/usr/share/fzf/completion.zsh" ]] && source /usr/share/fzf/completion.zsh
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"
```

Tries common paths for each plugin across different distros.

### Alias Modules

#### 50-aliases-universal.zsh
```bash
# Universal aliases that work on all systems
alias c="clear"
alias please="sudo"

# Modern command substitution (safer than backticks)
alias make="make -j\$(nproc 2>/dev/null || echo 4)"
alias ninja="ninja -j\$(nproc 2>/dev/null || echo 4)"
alias n="ninja"

# Safe ls aliases (if GNU coreutils available)
if ls --color=auto &>/dev/null; then
  alias ls="ls --color=auto"
  alias ll="ls -lh"
  alias la="ls -lha"
fi

# Git aliases (if git installed)
if command -v git &>/dev/null; then
  alias g="git"
  alias gs="git status"
  alias gd="git diff"
fi
```

#### 51-aliases-arch.zsh
```bash
# Only load on Arch-based systems
if [[ -f /etc/arch-release ]] || [[ -f /etc/cachyos-release ]]; then
  alias update="sudo pacman -Syu"
  alias install="sudo pacman -S"
  alias remove="sudo pacman -Rsn"
  alias search="pacman -Ss"
  alias cleanpkg="sudo pacman -Scc"
  alias fixpacman="sudo rm /var/lib/pacman/db.lck"

  # Safer cleanup with confirmation
  cleanup() {
    local orphans=$(pacman -Qtdq 2>/dev/null)
    if [[ -n "$orphans" ]]; then
      echo "Orphaned packages:"
      echo "$orphans"
      read "?Remove these packages? [y/N] " response
      if [[ "$response" =~ ^[Yy]$ ]]; then
        sudo pacman -Rsn $orphans
      fi
    else
      echo "No orphaned packages found."
    fi
  }

  # Help for people new to Arch
  alias apt="man pacman"
  alias apt-get="man pacman"

  # Other useful aliases
  alias jctl="journalctl -p 3 -xb"
  alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"
fi
```

**Security fixes from original config:**
- `cleanup` is now a function that shows packages before removing
- Uses `$()` instead of backticks for command substitution
- Asks for confirmation before destructive actions

#### 51-aliases-debian.zsh
```bash
# Only load on Debian-based systems
if [[ -f /etc/debian_version ]]; then
  alias update="sudo apt update && sudo apt upgrade"
  alias install="sudo apt install"
  alias remove="sudo apt remove"
  alias search="apt search"
  alias autoremove="sudo apt autoremove"
  alias purge="sudo apt purge"

  # Safer cleanup with confirmation
  cleanup() {
    echo "Packages that can be auto-removed:"
    apt --dry-run autoremove
    read "?Remove these packages? [y/N] " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      sudo apt autoremove
    fi
  }

  # System info
  alias sysinfo="inxi -Fxz"
  alias services="systemctl list-units --type=service"
fi
```

#### 51-aliases-fedora.zsh
```bash
# Only load on Fedora/RHEL-based systems
if [[ -f /etc/fedora-release ]] || [[ -f /etc/redhat-release ]]; then
  # Detect dnf vs yum
  if command -v dnf &>/dev/null; then
    alias update="sudo dnf upgrade"
    alias install="sudo dnf install"
    alias remove="sudo dnf remove"
    alias search="dnf search"
    alias cleanpkg="sudo dnf clean all"

    cleanup() {
      echo "Packages that can be auto-removed:"
      dnf list autoremove
      read "?Remove these packages? [y/N] " response
      if [[ "$response" =~ ^[Yy]$ ]]; then
        sudo dnf autoremove
      fi
    }
  else
    alias update="sudo yum update"
    alias install="sudo yum install"
    alias remove="sudo yum remove"
    alias search="yum search"
    alias cleanpkg="sudo yum clean all"
  fi

  # System info
  alias services="systemctl list-units --type=service"
fi
```

### Configuration Helper Scripts

Located in `.local/bin/`, these scripts help users install optional components.

#### configure-oh-my-zsh
```bash
#!/usr/bin/env bash
# Install Oh-My-Zsh if not present

set -e

if [[ -d "$HOME/.oh-my-zsh" ]]; then
  echo "Oh-My-Zsh already installed at ~/.oh-my-zsh"
  exit 0
fi

echo "Installing Oh-My-Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "Oh-My-Zsh installed successfully!"
echo "Restart your shell or run: source ~/.zshrc"
```

#### configure-powerlevel10k
```bash
#!/usr/bin/env bash
# Install Powerlevel10k theme

set -e

P10K_DIR="$HOME/.powerlevel10k"

if [[ -d "$P10K_DIR" ]]; then
  echo "Powerlevel10k already installed at $P10K_DIR"
  read -p "Update to latest version? [y/N] " response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    cd "$P10K_DIR" && git pull
    echo "Updated successfully!"
  fi
  exit 0
fi

echo "Installing Powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"

echo "Powerlevel10k installed successfully!"
echo "Run 'p10k configure' to set up your prompt"
echo "Restart your shell or run: source ~/.zshrc"
```

#### configure-zsh-plugins
```bash
#!/usr/bin/env bash
# Install zsh plugins (syntax-highlighting, autosuggestions, history-substring-search)

set -e

PLUGIN_DIR="$HOME/.zsh"
mkdir -p "$PLUGIN_DIR"

install_plugin() {
  local name="$1"
  local repo="$2"
  local target="$PLUGIN_DIR/$name"

  if [[ -d "$target" ]]; then
    echo "$name already installed"
    return
  fi

  echo "Installing $name..."
  git clone --depth=1 "$repo" "$target"
  echo "$name installed!"
}

install_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
install_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
install_plugin "zsh-history-substring-search" "https://github.com/zsh-users/zsh-history-substring-search.git"

echo ""
echo "All plugins installed successfully!"
echo "Restart your shell or run: source ~/.zshrc"
```

#### configure-fzf
```bash
#!/usr/bin/env bash
# Install FZF (fuzzy finder)

set -e

FZF_DIR="$HOME/.fzf"

if [[ -d "$FZF_DIR" ]]; then
  echo "FZF already installed at $FZF_DIR"
  read -p "Update to latest version? [y/N] " response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    cd "$FZF_DIR" && git pull
    "$FZF_DIR/install" --key-bindings --completion --no-update-rc
    echo "Updated successfully!"
  fi
  exit 0
fi

echo "Installing FZF..."
git clone --depth=1 https://github.com/junegunn/fzf.git "$FZF_DIR"
"$FZF_DIR/install" --key-bindings --completion --no-update-rc

echo "FZF installed successfully!"
echo "Restart your shell or run: source ~/.zshrc"
```

## Deployment with GNU Stow

### Stow Command
```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh  # Uses config.yaml to deploy zsh module
```

### What Gets Deployed
When `stow zsh` runs, it creates:
- `~/.zshrc` → symlink to `dotfiles/zsh/.zshrc`
- `~/.config/zsh/` → symlink to `dotfiles/zsh/.config/zsh/`
- `~/.local/bin/configure-*` → symlinks to the helper scripts

### Same Deployment, Different Behavior
All files are deployed to all systems. Runtime detection determines what actually executes:
- On CachyOS: Arch aliases load, Oh-My-Zsh/P10k load if installed
- On Ubuntu: Debian aliases load, plugins load if available, falls back to basic zsh
- On Fedora: Fedora aliases load, similar conditional behavior

## Security Improvements

### Fixed from Original CachyOS Config

1. **Dangerous cleanup alias** → Safe function with confirmation
   - Before: `alias cleanup="sudo pacman -Rsn $(pacman -Qtdq)"`
   - After: Function that shows packages and asks for confirmation

2. **Deprecated backticks** → Modern command substitution
   - Before: ``alias make="make -j`nproc`"``
   - After: `alias make="make -j$(nproc 2>/dev/null || echo 4)"`

3. **Command substitution safety** → Fallback values
   - Added `2>/dev/null || echo 4` to handle missing `nproc`

## Testing Strategy

### Per-System Verification
On each target system, verify:
1. `.zshrc` loads without errors
2. Appropriate distro aliases are available
3. Optional plugins work if installed
4. Shell performance is acceptable
5. Helper scripts are executable and work

### Test Commands
```bash
# Test basic loading
zsh -c 'source ~/.zshrc && echo "OK"'

# Check what loaded
zsh -c 'source ~/.zshrc && alias | grep update'

# Verify helper scripts
which configure-oh-my-zsh
configure-oh-my-zsh --help || true
```

## Future Extensions

Easy to extend with additional distro support:
1. Add `51-aliases-<distro>.zsh` with detection check
2. Add detection files to check (e.g., `/etc/gentoo-release`)
3. Define appropriate package manager aliases

Example for Alpine:
```bash
# 51-aliases-alpine.zsh
if [[ -f /etc/alpine-release ]]; then
  alias update="sudo apk update && sudo apk upgrade"
  alias install="sudo apk add"
  alias remove="sudo apk del"
  alias search="apk search"
fi
```

## Success Criteria

- ✅ Single stow command deploys to all systems
- ✅ Works on CachyOS, Ubuntu, Fedora without modification
- ✅ Gracefully degrades when tools unavailable
- ✅ Helper scripts allow optional tool installation
- ✅ Security issues from original config fixed
- ✅ XDG Base Directory compliant
- ✅ Maintainable: easy to add new distros or plugins
