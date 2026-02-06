# Portable Fish Shell Configuration Design

**Date:** 2026-02-06
**Status:** Approved
**Target Systems:** HOME-DESKTOP, local, work (mixed Linux distributions)

## Overview

Design a portable fish shell configuration that works across multiple Linux distributions (CachyOS, Arch, Ubuntu, Fedora) using fish's native features. Similar to the zsh configuration, but leveraging fish-specific capabilities like automatic conf.d/ sourcing, fish_add_path, and the fisher plugin manager.

## Requirements

1. **Portability**: Single configuration deployed to all systems via GNU Stow
2. **Native Fish Features**: Use fish idioms (conf.d/, fish_add_path, set -gx, test)
3. **Fisher Plugin Management**: Declarative plugins via fish_plugins file
4. **CachyOS Integration**: Conditionally source CachyOS config on CachyOS systems
5. **Distro-Specific Features**: Load distro-appropriate aliases based on system detection
6. **Consistency with Zsh**: Similar structure to zsh config for maintainability

## Architecture

### Approach: Fish-Native with Conditional Loading

- Minimal `config.fish` - fish automatically sources `conf.d/*.fish`
- `conf.d/` directory with auto-loading configuration modules
- Only `00-` prefix for environment (critical load order), rest alphabetical
- Distro-specific modules use fish's `test` for conditional execution
- Fisher manages plugins declaratively via `fish_plugins` file
- Helper scripts for fisher and tide installation

### Directory Structure

```
dotfiles/fish/
├── .config/
│   └── fish/
│       ├── config.fish                    # Minimal entry point
│       ├── fish_plugins                   # Fisher plugin declarations
│       └── conf.d/                        # Auto-sourced by fish
│           ├── 00-environment.fish        # PATH, env vars (loads first)
│           ├── aliases-universal.fish     # Cross-platform aliases
│           ├── aliases-arch.fish          # Arch/CachyOS (conditional)
│           ├── aliases-debian.fish        # Debian/Ubuntu (conditional)
│           ├── aliases-fedora.fish        # Fedora/RHEL (conditional)
│           └── cachyos.fish               # CachyOS integration (conditional)
└── .local/
    └── bin/
        ├── configure-fisher               # Install fisher + plugins
        └── configure-tide                 # Configure tide prompt
```

**Naming Convention:**
- `00-` prefix: Critical load-order files (environment)
- Descriptive names: Files that can load in any order
- Alphabetical loading: Leverages fish's native conf.d/ behavior

## Component Details

### Main Entry Point: config.fish

```fish
# ~/.config/fish/config.fish
# Portable fish configuration
# Note: Files in conf.d/ are automatically sourced by fish

# Machine-specific overrides (not in stow)
if test -f ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end
```

**Features:**
- Minimal - fish does the heavy lifting
- Supports local overrides via `config.local.fish`
- Documents that conf.d/ is auto-sourced

### Environment Configuration: 00-environment.fish

```fish
# ~/.config/fish/conf.d/00-environment.fish
# Environment setup - must load first

# Add user binary directories to PATH
fish_add_path $HOME/.local/bin $HOME/bin

# Set default editor
set -gx EDITOR vim
set -gx VISUAL vim

# XDG Base Directory specification
set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME $HOME/.config
set -q XDG_CACHE_HOME; or set -gx XDG_CACHE_HOME $HOME/.cache
set -q XDG_DATA_HOME; or set -gx XDG_DATA_HOME $HOME/.local/share
```

**Fish-native features:**
- `fish_add_path` - Idiomatic way to add to PATH
- `set -gx` - Export global variable
- `set -q VAR; or set -gx VAR value` - Set if not already set

### CachyOS Integration: cachyos.fish

```fish
# ~/.config/fish/conf.d/cachyos.fish
# CachyOS-specific configuration - loads only on CachyOS

if test -f /etc/cachyos-release
    and test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end
```

**Features:**
- Checks for both CachyOS system and config file
- Uses fish's `and` operator for clean conditionals
- Gracefully skips on non-CachyOS systems

### Universal Aliases: aliases-universal.fish

```fish
# ~/.config/fish/conf.d/aliases-universal.fish
# Cross-platform aliases

# Basic shortcuts
alias c='clear'
alias please='sudo'

# Git shortcuts (if git installed)
if command -v git &>/dev/null
    alias g='git'
    alias gs='git status'
    alias gd='git diff'
    alias ga='git add'
    alias gc='git commit'
    alias gp='git push'
    alias gl='git log --oneline --graph --decorate'
end

# Safety aliases
alias cp='cp -i'    # Prompt before overwrite
alias mv='mv -i'    # Prompt before overwrite
alias rm='rm -i'    # Prompt before delete

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Process management
alias ps='ps auxf'

# Network
alias ports='netstat -tulanp'
alias listening='lsof -i -P | grep LISTEN'
```

### Arch Linux Aliases: aliases-arch.fish

```fish
# ~/.config/fish/conf.d/aliases-arch.fish
# Arch Linux / CachyOS specific aliases

if test -f /etc/arch-release; or test -f /etc/cachyos-release

    # Package management
    alias update='sudo pacman -Syu'
    alias install='sudo pacman -S'
    alias remove='sudo pacman -Rsn'
    alias search='pacman -Ss'
    alias cleanpkg='sudo pacman -Scc'
    alias fixpacman='sudo rm /var/lib/pacman/db.lck'

    # Safer cleanup function with confirmation
    function cleanup
        set orphans (pacman -Qtdq 2>/dev/null)
        if test -n "$orphans"
            echo "Orphaned packages:"
            echo $orphans
            read -P "Remove these packages? [y/N] " -l response
            if test "$response" = y; or test "$response" = Y
                sudo pacman -Rsn $orphans
            else
                echo "Cancelled."
            end
        else
            echo "No orphaned packages found."
        end
    end

    # Help for people new to Arch
    alias apt='man pacman'
    alias yum='man pacman'
    alias dnf='man pacman'

    # System information
    alias jctl='journalctl -p 3 -xb'
    alias rip='expac --timefmt=\'%Y-%m-%d %T\' \'%l\t%n %v\' | sort | tail -200 | nl'

    # AUR helper aliases (if installed)
    if command -v yay &>/dev/null
        alias yaupdate='yay -Syu'
        alias yain='yay -S'
        alias yarem='yay -Rsn'
        alias yasearch='yay -Ss'
    else if command -v paru &>/dev/null
        alias parupdate='paru -Syu'
        alias parain='paru -S'
        alias pararem='paru -Rsn'
        alias parasearch='paru -Ss'
    end

end
```

**Fish-native features:**
- `function` keyword for defining functions
- `set variable (command)` for command substitution
- `test` for conditionals
- `read -P` for prompts
- `if/else if/else/end` blocks

### Debian Aliases: aliases-debian.fish

```fish
# ~/.config/fish/conf.d/aliases-debian.fish
# Debian / Ubuntu specific aliases

if test -f /etc/debian_version

    # Package management
    alias update='sudo apt update && sudo apt upgrade'
    alias install='sudo apt install'
    alias remove='sudo apt remove'
    alias search='apt search'
    alias autoremove='sudo apt autoremove'
    alias purge='sudo apt purge'
    alias aptclean='sudo apt clean && sudo apt autoclean'

    # Safer cleanup function with confirmation
    function cleanup
        echo "Packages that can be auto-removed:"
        apt --dry-run autoremove 2>/dev/null
        read -P "Remove these packages? [y/N] " -l response
        if test "$response" = y; or test "$response" = Y
            sudo apt autoremove
        else
            echo "Cancelled."
        end
    end

    # System information
    alias sysinfo='inxi -Fxz 2>/dev/null || lsb_release -a'
    alias services='systemctl list-units --type=service'
    alias logs='journalctl -xe'

    # Snap aliases (if snapd installed)
    if command -v snap &>/dev/null
        alias snapup='sudo snap refresh'
        alias snapin='sudo snap install'
        alias snaprm='sudo snap remove'
        alias snapls='snap list'
    end

end
```

### Fedora Aliases: aliases-fedora.fish

```fish
# ~/.config/fish/conf.d/aliases-fedora.fish
# Fedora / RHEL specific aliases

if test -f /etc/fedora-release; or test -f /etc/redhat-release

    # Detect dnf vs yum
    if command -v dnf &>/dev/null
        # DNF (modern Fedora/RHEL)
        alias update='sudo dnf upgrade'
        alias install='sudo dnf install'
        alias remove='sudo dnf remove'
        alias search='dnf search'
        alias cleanpkg='sudo dnf clean all'
        alias info='dnf info'

        # Safer cleanup function
        function cleanup
            echo "Packages that can be auto-removed:"
            dnf list autoremove 2>/dev/null
            read -P "Remove these packages? [y/N] " -l response
            if test "$response" = y; or test "$response" = Y
                sudo dnf autoremove
            else
                echo "Cancelled."
            end
        end

    else
        # YUM (older RHEL/CentOS)
        alias update='sudo yum update'
        alias install='sudo yum install'
        alias remove='sudo yum remove'
        alias search='yum search'
        alias cleanpkg='sudo yum clean all'
        alias info='yum info'
    end

    # System information
    alias services='systemctl list-units --type=service'
    alias logs='journalctl -xe'
    alias firewall='sudo firewall-cmd --list-all'

    # SELinux helpers
    if command -v getenforce &>/dev/null
        alias selinux-status='getenforce'
        alias selinux-permissive='sudo setenforce 0'
        alias selinux-enforcing='sudo setenforce 1'
    end

end
```

### Plugin Management: fish_plugins

```
jorgebucaran/fisher
jorgebucaran/nvm.fish
IlanCosman/tide@v6
jethrokuan/z
```

**Plugins:**
- `fisher` - Plugin manager itself (bootstraps the system)
- `nvm.fish` - Node version manager (user already uses this)
- `tide@v6` - Modern, fast, customizable prompt (fish's powerlevel10k)
- `z` - Smart directory jumping based on frecency

**Plugin installation:** Fisher reads this file and installs all plugins automatically when you run `fisher update`.

### Helper Scripts

#### configure-fisher

```bash
#!/usr/bin/env bash
# Install Fisher and plugins

set -e

echo "==================================="
echo "Fisher Plugin Manager Setup"
echo "==================================="
echo ""

# Check if fisher is already installed
if fish -c "type -q fisher" 2>/dev/null; then
    echo "✓ Fisher already installed"
    echo ""
    read -p "Update all plugins? [y/N] " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Updating plugins from fish_plugins..."
        fish -c "fisher update"
        echo "✓ Plugins updated!"
    fi
    exit 0
fi

# Install fisher
echo "Installing Fisher..."
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

echo ""
echo "✓ Fisher installed successfully!"
echo ""
echo "Installing plugins from fish_plugins..."
fish -c "fisher update"

echo ""
echo "✓ All plugins installed!"
echo ""
echo "Next steps:"
echo "  - Restart fish or run: exec fish"
echo "  - Run 'configure-tide' to set up your prompt"
```

#### configure-tide

```bash
#!/usr/bin/env bash
# Configure Tide prompt

set -e

echo "==================================="
echo "Tide Prompt Configuration"
echo "==================================="
echo ""

# Check if tide is installed
if ! fish -c "type -q tide" 2>/dev/null; then
    echo "✗ Tide is not installed"
    echo ""
    echo "Please run 'configure-fisher' first to install plugins."
    exit 1
fi

echo "Launching Tide configuration wizard..."
echo "(This will open an interactive prompt customizer)"
echo ""

# Run tide configure
fish -c "tide configure"

echo ""
echo "✓ Tide configuration complete!"
```

## Deployment with GNU Stow

### Stow Command
```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh  # Uses config.yaml to deploy fish module
```

### What Gets Deployed
When `stow fish` runs, it creates:
- `~/.config/fish/config.fish` → symlink to `dotfiles/fish/.config/fish/config.fish`
- `~/.config/fish/fish_plugins` → symlink to `dotfiles/fish/.config/fish/fish_plugins`
- `~/.config/fish/conf.d/` → symlink to `dotfiles/fish/.config/fish/conf.d/`
- `~/.local/bin/configure-*` → symlinks to the helper scripts

### Same Deployment, Different Behavior
All files are deployed to all systems. Runtime detection determines what actually executes:
- On CachyOS: CachyOS config loads, Arch aliases load
- On Ubuntu: Debian aliases load, works without CachyOS config
- On Fedora: Fedora aliases load, similar conditional behavior

## Key Differences from Zsh Configuration

| Feature | Zsh | Fish |
|---------|-----|------|
| **Module Loading** | Manual loop in .zshrc | Automatic conf.d/ sourcing |
| **PATH Management** | `export PATH=...` | `fish_add_path` |
| **Variables** | `export VAR=value` | `set -gx VAR value` |
| **Conditionals** | `[[ -f file ]]` | `test -f file` |
| **Functions** | `function_name() { }` | `function function_name; ...; end` |
| **Plugin Manager** | Manual git clone | Fisher with fish_plugins |
| **Prompt** | Powerlevel10k | Tide |
| **Load Order** | Numbered prefixes (00-, 10-, etc.) | Minimal prefixes (00- only) |

## Fish-Specific Best Practices

1. **Use native features**: `fish_add_path`, `set -gx`, `test`
2. **Leverage conf.d/**: Let fish auto-source instead of manual loops
3. **Minimal prefixes**: Only use numbers where load order truly matters
4. **Fisher for plugins**: Declarative plugin management
5. **Functions over aliases**: For complex operations, use `function`
6. **Avoid bash syntax**: Fish is not POSIX-compatible, use fish idioms

## Testing Strategy

### Per-System Verification
On each target system, verify:
1. `config.fish` loads without errors
2. Appropriate distro aliases are available
3. Fisher and plugins work correctly
4. CachyOS config loads on CachyOS (if applicable)
5. Helper scripts are executable

### Test Commands
```bash
# Test basic loading
fish -c 'echo "OK"'

# Check what aliases loaded
fish -c 'alias | grep update'

# Verify fisher installed
fish -c 'type -q fisher && echo "Fisher OK"'

# Verify helper scripts
which configure-fisher
```

## Future Extensions

Easy to extend with additional distro support:
1. Add `conf.d/aliases-<distro>.fish` with detection check
2. Define appropriate package manager aliases
3. Use fish syntax (`function`, `test`, `set`)

Example for Alpine:
```fish
# conf.d/aliases-alpine.fish
if test -f /etc/alpine-release
    alias update='sudo apk update && sudo apk upgrade'
    alias install='sudo apk add'
    alias remove='sudo apk del'
    alias search='apk search'
end
```

## Success Criteria

- ✅ Single stow command deploys to all systems
- ✅ Works on CachyOS, Ubuntu, Fedora without modification
- ✅ Uses fish-native features (conf.d/, fish_add_path, etc.)
- ✅ Fisher manages plugins declaratively
- ✅ CachyOS config loads only on CachyOS
- ✅ Distro-specific aliases work correctly
- ✅ Helper scripts allow optional tool installation
- ✅ Consistent with zsh configuration structure
- ✅ Maintainable: easy to add new distros or plugins

## References

- [Fish Shell Documentation](https://fishshell.com/docs/current/)
- [Fisher Plugin Manager](https://github.com/jorgebucaran/fisher)
- [Tide Prompt](https://github.com/IlanCosman/tide)
- [Fish Design Document](https://fishshell.com/docs/current/design.html)
