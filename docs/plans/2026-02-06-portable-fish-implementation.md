# Portable Fish Shell Configuration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a portable, modular fish shell configuration that works across multiple Linux distributions using fish-native features and graceful degradation.

**Architecture:** Fish-native modular configuration in `~/.config/fish/conf.d/` with automatic sourcing. Minimal `config.fish`, declarative plugin management via fisher and fish_plugins, conditional distro-specific loading. Helper scripts in `~/.local/bin/` for optional tool setup.

**Tech Stack:** Fish shell, Fisher plugin manager, GNU Stow, Bash (for helper scripts), Git

---

## Task 1: Create Directory Structure

**Files:**
- Create: `fish/.config/fish/` (directory)
- Create: `fish/.config/fish/conf.d/` (directory)
- Create: `fish/.local/bin/` (directory)

**Step 1: Create the fish stow module directory structure**

```bash
cd /home/anirudh/.local/share/dotfiles
mkdir -p fish/.config/fish/conf.d
mkdir -p fish/.local/bin
```

**Step 2: Verify directory structure**

Run: `find fish/ -type d`
Expected: Shows fish/, .config/fish/, conf.d/, and .local/bin/ directories

**Step 3: Commit structure**

```bash
git add fish/
git commit -m "feat(fish): create module directory structure

- Add fish stow module skeleton
- Create config and conf.d directories
- Add bin directory for helper scripts

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 2: Create Main config.fish Entry Point

**Files:**
- Create: `fish/.config/fish/config.fish`

**Step 1: Write the main config.fish file**

```fish
# ~/.config/fish/config.fish
# Portable fish configuration
# Note: Files in conf.d/ are automatically sourced by fish

# Machine-specific overrides (not in stow)
if test -f ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end
```

**Step 2: Verify syntax**

Run: `fish -n fish/.config/fish/config.fish`
Expected: No output (syntax OK)

**Step 3: Commit**

```bash
git add fish/.config/fish/config.fish
git commit -m "feat(fish): add main config.fish entry point

- Minimal config, fish auto-sources conf.d/
- Supports local overrides via config.local.fish

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 3: Create Environment Module

**Files:**
- Create: `fish/.config/fish/conf.d/00-environment.fish`

**Step 1: Write environment configuration**

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

**Step 2: Verify syntax**

Run: `fish -n fish/.config/fish/conf.d/00-environment.fish`
Expected: No output (syntax OK)

**Step 3: Commit**

```bash
git add fish/.config/fish/conf.d/00-environment.fish
git commit -m "feat(fish): add environment configuration module

- Set up PATH with fish_add_path
- Configure default editor
- Define XDG Base Directory variables

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 4: Create CachyOS Integration Module

**Files:**
- Create: `fish/.config/fish/conf.d/cachyos.fish`

**Step 1: Write CachyOS configuration**

```fish
# ~/.config/fish/conf.d/cachyos.fish
# CachyOS-specific configuration - loads only on CachyOS

if test -f /etc/cachyos-release
    and test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end
```

**Step 2: Verify syntax**

Run: `fish -n fish/.config/fish/conf.d/cachyos.fish`
Expected: No output (syntax OK)

**Step 3: Commit**

```bash
git add fish/.config/fish/conf.d/cachyos.fish
git commit -m "feat(fish): add CachyOS integration module

- Conditionally sources CachyOS config
- Only loads on CachyOS systems
- Gracefully skips elsewhere

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 5: Create Universal Aliases Module

**Files:**
- Create: `fish/.config/fish/conf.d/aliases-universal.fish`

**Step 1: Write universal aliases**

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

**Step 2: Verify syntax**

Run: `fish -n fish/.config/fish/conf.d/aliases-universal.fish`
Expected: No output (syntax OK)

**Step 3: Commit**

```bash
git add fish/.config/fish/conf.d/aliases-universal.fish
git commit -m "feat(fish): add universal aliases module

- Cross-platform aliases
- Git shortcuts if available
- Safety aliases for destructive commands

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 6: Create Arch Linux Aliases Module

**Files:**
- Create: `fish/.config/fish/conf.d/aliases-arch.fish`

**Step 1: Write Arch-specific aliases**

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

**Step 2: Verify syntax**

Run: `fish -n fish/.config/fish/conf.d/aliases-arch.fish`
Expected: No output (syntax OK)

**Step 3: Commit**

```bash
git add fish/.config/fish/conf.d/aliases-arch.fish
git commit -m "feat(fish): add Arch Linux aliases module

- Pacman package management shortcuts
- Safe cleanup function with confirmation
- Help aliases for users from other distros
- AUR helper support (yay/paru)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 7: Create Debian/Ubuntu Aliases Module

**Files:**
- Create: `fish/.config/fish/conf.d/aliases-debian.fish`

**Step 1: Write Debian-specific aliases**

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

**Step 2: Verify syntax**

Run: `fish -n fish/.config/fish/conf.d/aliases-debian.fish`
Expected: No output (syntax OK)

**Step 3: Commit**

```bash
git add fish/.config/fish/conf.d/aliases-debian.fish
git commit -m "feat(fish): add Debian/Ubuntu aliases module

- APT package management shortcuts
- Safe cleanup with dry-run preview
- System info and service management
- Snap support if installed

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 8: Create Fedora/RHEL Aliases Module

**Files:**
- Create: `fish/.config/fish/conf.d/aliases-fedora.fish`

**Step 1: Write Fedora-specific aliases**

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

**Step 2: Verify syntax**

Run: `fish -n fish/.config/fish/conf.d/aliases-fedora.fish`
Expected: No output (syntax OK)

**Step 3: Commit**

```bash
git add fish/.config/fish/conf.d/aliases-fedora.fish
git commit -m "feat(fish): add Fedora/RHEL aliases module

- DNF/YUM package management shortcuts
- Safe cleanup with preview
- System and service management
- SELinux helpers

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 9: Create fish_plugins File

**Files:**
- Create: `fish/.config/fish/fish_plugins`

**Step 1: Write fish_plugins file**

```
jorgebucaran/fisher
jorgebucaran/nvm.fish
IlanCosman/tide@v6
jethrokuan/z
```

**Step 2: Verify file exists**

Run: `cat fish/.config/fish/fish_plugins`
Expected: Shows the 4 plugin lines

**Step 3: Commit**

```bash
git add fish/.config/fish/fish_plugins
git commit -m "feat(fish): add fish_plugins for fisher

- Fisher plugin manager
- nvm.fish for Node version management
- Tide prompt (v6)
- z for smart directory jumping

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 10: Create Fisher Installation Script

**Files:**
- Create: `fish/.local/bin/configure-fisher`

**Step 1: Write the installation script**

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

**Step 2: Make script executable**

Run: `chmod +x fish/.local/bin/configure-fisher`
Expected: No output

**Step 3: Verify script syntax**

Run: `bash -n fish/.local/bin/configure-fisher`
Expected: No output (syntax OK)

**Step 4: Commit**

```bash
git add fish/.local/bin/configure-fisher
git commit -m "feat(fish): add Fisher installation script

- Installs Fisher plugin manager
- Updates plugins from fish_plugins file
- Checks if already installed

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 11: Create Tide Configuration Script

**Files:**
- Create: `fish/.local/bin/configure-tide`

**Step 1: Write the configuration script**

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

**Step 2: Make script executable**

Run: `chmod +x fish/.local/bin/configure-tide`
Expected: No output

**Step 3: Verify script syntax**

Run: `bash -n fish/.local/bin/configure-tide`
Expected: No output (syntax OK)

**Step 4: Commit**

```bash
git add fish/.local/bin/configure-tide
git commit -m "feat(fish): add Tide configuration script

- Launches Tide prompt customizer
- Checks if Tide is installed first
- Provides guidance if missing

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 12: Update config.yaml for Fish Module

**Files:**
- Modify: `config.yaml`

**Step 1: Add fish module to config.yaml**

Add the following entry to the modules list:

```yaml
  - name: "fish"
    path: "fish"
    hosts:
      - HOME-DESKTOP
      - local
      - work
```

**Step 2: Verify YAML syntax**

Run: `yq -r '.' config.yaml > /dev/null`
Expected: No output (valid YAML)

**Step 3: View updated config**

Run: `yq -r '.modules[] | select(.name == "fish")' config.yaml`
Expected: Shows the fish module configuration

**Step 4: Commit**

```bash
git add config.yaml
git commit -m "feat(fish): add fish module to stow configuration

- Deploy fish config to all hosts
- Includes modular configs and helper scripts

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 13: Create README for Fish Module

**Files:**
- Create: `fish/README.md`

**Step 1: Write the README**

```markdown
# Fish Shell Configuration Module

Portable, modular fish shell configuration that works across multiple Linux distributions using fish-native features.

## Features

- **Fish-native design** - Uses conf.d/, fish_add_path, fisher
- **Automatic loading** - Fish auto-sources conf.d/*.fish files
- **Graceful degradation** - Works without optional plugins
- **Distro-specific aliases** - Arch, Debian/Ubuntu, Fedora/RHEL support
- **CachyOS integration** - Loads CachyOS config on CachyOS systems
- **Fisher plugin management** - Declarative plugins via fish_plugins

## Deployment

```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh
```

This deploys:
- `~/.config/fish/config.fish` - minimal entry point
- `~/.config/fish/fish_plugins` - plugin declarations
- `~/.config/fish/conf.d/*.fish` - modular configuration files
- `~/.local/bin/configure-*` - helper scripts

## Module Load Order

Fish automatically sources files in `conf.d/` alphabetically:

- `00-environment.fish` - PATH and environment variables (loads first)
- `aliases-arch.fish` - Arch Linux specific (if on Arch)
- `aliases-debian.fish` - Debian/Ubuntu specific (if on Debian)
- `aliases-fedora.fish` - Fedora/RHEL specific (if on Fedora)
- `aliases-universal.fish` - Cross-platform aliases
- `cachyos.fish` - CachyOS integration (if on CachyOS)

## Optional Tool Installation

Helper scripts in `~/.local/bin/`:

```bash
# Install Fisher and plugins
configure-fisher

# Configure Tide prompt
configure-tide
```

## Plugins Included

Managed via `fish_plugins` and installed with `configure-fisher`:

- **fisher** - Plugin manager
- **nvm.fish** - Node version manager
- **tide** - Modern, customizable prompt
- **z** - Smart directory jumping

## Machine-Specific Overrides

Create `~/.config/fish/config.local.fish` for machine-specific customizations not managed by stow:

```fish
# Example: work machine proxy
set -gx HTTP_PROXY http://proxy.example.com:8080
set -gx HTTPS_PROXY http://proxy.example.com:8080
```

## Customization

### Add New Distro Support

Create `fish/.config/fish/conf.d/aliases-<distro>.fish`:

```fish
if test -f /etc/<distro>-release
    alias update='sudo <package-manager> update'
    # ... more aliases
end
```

### Add Personal Aliases

Edit `fish/.config/fish/conf.d/aliases-universal.fish` or create `~/.config/fish/config.local.fish`

### Add Plugins

Edit `fish/.config/fish/fish_plugins`, add plugin repo, run `configure-fisher`

## Fish-Native Features

This configuration uses fish idioms:

- `fish_add_path` - Add directories to PATH
- `set -gx` - Export global variables
- `set -q VAR; or set -gx VAR value` - Set if not already set
- `test` - Conditionals (instead of `[[]]`)
- `function/end` - Define functions
- `conf.d/` - Automatic module loading

## Troubleshooting

### Check what modules loaded
```bash
ls ~/.config/fish/conf.d/*.fish
```

### Test syntax of all files
```bash
for f in ~/.config/fish/conf.d/*.fish; fish -n $f && echo "✓ $f"; end
```

### Verify distro detection
```bash
ls /etc/*-release
```

### Check if fisher is installed
```fish
type -q fisher && echo "Fisher OK" || echo "Fisher missing"
```

## References

- [Fish Shell Documentation](https://fishshell.com/docs/current/)
- [Fisher Plugin Manager](https://github.com/jorgebucaran/fisher)
- [Tide Prompt](https://github.com/IlanCosman/tide)
- [nvm.fish](https://github.com/jorgebucaran/nvm.fish)
```

**Step 2: Commit**

```bash
git add fish/README.md
git commit -m "docs(fish): add comprehensive module README

- Explain features and deployment
- Document module load order
- Provide customization guide
- Include troubleshooting tips

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 14: Test Configuration Syntax

**Files:**
- Test: All `.fish` files

**Step 1: Test all fish configuration files**

```bash
cd /home/anirudh/.local/share/dotfiles
for f in fish/.config/fish/config.fish fish/.config/fish/conf.d/*.fish; do
  echo "Testing: $f"
  fish -n "$f" && echo "  ✓ Syntax OK" || echo "  ✗ Syntax Error"
done
```

Expected: All files show "✓ Syntax OK"

**Step 2: Test all bash helper scripts**

```bash
for f in fish/.local/bin/configure-*; do
  echo "Testing: $f"
  bash -n "$f" && echo "  ✓ Syntax OK" || echo "  ✗ Syntax Error"
done
```

Expected: All files show "✓ Syntax OK"

**Step 3: Verify file permissions**

```bash
ls -l fish/.local/bin/
```

Expected: All configure-* scripts should be executable (rwxr-xr-x)

---

## Task 15: Test Deployment with Stow

**Files:**
- Test: Entire fish module deployment

**Step 1: Backup existing fish configuration**

```bash
if test -d "$HOME/.config/fish"; then
  cp -r "$HOME/.config/fish" "$HOME/.config/fish.backup.$(date +%Y%m%d)"
  echo "Backed up existing fish config"
fi
```

**Step 2: Deploy fish module using stow**

```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh
```

Expected: No errors, stow creates symlinks

**Step 3: Verify symlinks created**

```bash
ls -la ~/.config/fish/config.fish ~/.config/fish/conf.d ~/.local/bin/configure-fisher
```

Expected: All are symlinks pointing to dotfiles/fish/

**Step 4: Test loading the configuration**

```bash
fish -c 'echo "✓ Config loaded successfully"'
```

Expected: "✓ Config loaded successfully"

**Step 5: Check which modules loaded and aliases available**

```bash
fish -c 'alias | grep -E "update|install|remove" | head -5'
```

Expected: Shows distro-appropriate aliases

---

## Task 16: Create Deployment Summary Document

**Files:**
- Create: `docs/plans/2026-02-06-portable-fish-deployment-summary.md`

**Step 1: Write deployment summary**

```markdown
# Portable Fish Shell Configuration - Deployment Summary

**Date:** 2026-02-06
**Status:** Complete

## What Was Built

A portable, modular fish shell configuration that:
- Works across multiple Linux distributions (Arch, Debian, Fedora)
- Uses fish-native features (conf.d/, fish_add_path, fisher)
- Automatically loads modular configurations
- Conditionally loads CachyOS config on CachyOS
- Provides distro-specific aliases with runtime detection
- Manages plugins declaratively via fish_plugins

## Files Created

### Configuration Files
- `fish/.config/fish/config.fish` - Minimal entry point
- `fish/.config/fish/fish_plugins` - Fisher plugin declarations
- `fish/.config/fish/conf.d/00-environment.fish` - Environment setup
- `fish/.config/fish/conf.d/cachyos.fish` - CachyOS integration
- `fish/.config/fish/conf.d/aliases-universal.fish` - Universal aliases
- `fish/.config/fish/conf.d/aliases-arch.fish` - Arch-specific
- `fish/.config/fish/conf.d/aliases-debian.fish` - Debian-specific
- `fish/.config/fish/conf.d/aliases-fedora.fish` - Fedora-specific

### Helper Scripts
- `fish/.local/bin/configure-fisher` - Install Fisher + plugins
- `fish/.local/bin/configure-tide` - Configure Tide prompt

### Documentation
- `fish/README.md` - Module documentation
- `docs/plans/2026-02-06-portable-fish-design.md` - Design document
- `docs/plans/2026-02-06-portable-fish-implementation.md` - This plan

## Deployment

```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh
```

Deploys to hosts: HOME-DESKTOP, local, work

## Post-Deployment Steps

### Optional Tool Installation

```bash
# Install Fisher and plugins
configure-fisher

# Configure Tide prompt
configure-tide
```

### Verify Configuration

```bash
# Test config loads
fish -c 'echo OK'

# Check distro-specific aliases
fish -c 'alias | grep update'

# Verify fisher installed
fish -c 'type -q fisher && echo "Fisher OK"'
```

## System-Specific Behavior

### On CachyOS (current system)
- CachyOS config loaded from /usr/share/cachyos-fish-config/
- Arch aliases loaded (pacman shortcuts)
- Native nvm.fish support

### On Ubuntu/Debian systems
- Debian aliases loaded (apt shortcuts)
- Snap aliases if snapd installed
- Works without CachyOS config

### On Fedora/RHEL systems
- Fedora aliases loaded (dnf/yum shortcuts)
- SELinux helpers available
- Detects dnf vs yum automatically

## Fish-Native Features Used

- ✅ `conf.d/` automatic sourcing
- ✅ `fish_add_path` for PATH management
- ✅ `set -gx` for environment variables
- ✅ `test` for conditionals
- ✅ `function/end` for functions
- ✅ Fisher for plugin management
- ✅ Minimal numbered prefixes (00- only)

## Success Criteria Met

- ✅ Single stow deployment to all systems
- ✅ Works across CachyOS, Ubuntu, Fedora
- ✅ Uses fish-native features
- ✅ CachyOS integration when present
- ✅ Distro-specific aliases work correctly
- ✅ Fisher manages plugins declaratively
- ✅ Helper scripts for optional tools
- ✅ Consistent with zsh configuration structure
- ✅ Easy to extend with new distros

## Comparison with Zsh Configuration

| Feature | Zsh | Fish |
|---------|-----|------|
| Module Loading | Manual loop | Automatic conf.d/ |
| PATH | export PATH= | fish_add_path |
| Variables | export VAR= | set -gx VAR |
| Conditionals | [[ ]] | test |
| Functions | name() { } | function name; end |
| Plugin Manager | Manual + helpers | Fisher + fish_plugins |
| Prompt | Powerlevel10k | Tide |
| Load Order | Many prefixes | Minimal prefixes |

## Future Enhancements

Easy extensions:
- Add more distro-specific alias files
- Add more plugins to fish_plugins
- Customize Tide prompt themes
- Add abbreviations (fish's command expansion)

## References

- Design: `docs/plans/2026-02-06-portable-fish-design.md`
- Module README: `fish/README.md`
- Config: `config.yaml` (fish module entry)
```

**Step 2: Commit**

```bash
git add docs/plans/2026-02-06-portable-fish-deployment-summary.md
git commit -m "docs(fish): add deployment summary

- Document what was built
- List all created files
- Provide post-deployment steps
- Compare with zsh configuration

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Completion

All tasks complete! The portable fish configuration is:

✅ Designed (design document)
✅ Implemented (all config files and scripts)
✅ Documented (README and summary)
✅ Tested (syntax validation and deployment)
✅ Deployed (via GNU Stow)

The configuration works across multiple Linux distributions using fish-native features and provides helper scripts for optional tool installation.
