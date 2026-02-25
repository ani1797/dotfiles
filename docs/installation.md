# Installation Guide

This guide covers installing and setting up the dotfiles system on a new machine.

## Prerequisites

The installer will attempt to auto-install some prerequisites, but these must be available from your system's package manager:

### Required (Will Fail If Missing)

- **stow** - GNU Stow for symlink management
- **yq** - YAML processor for parsing configuration files
- **git** - Version control (for cloning this repository)
- **Python 3 with pip** - Required for pip: prefixed packages

### Auto-Installed (If Missing)

- **cargo** - Rust package manager (installed via rustup)
- **paru** - AUR helper (Arch only, installed via makepkg)

### Platform-Specific Package Managers

- **Arch/Manjaro/CachyOS:** pacman (built-in)
- **Debian/Ubuntu:** apt (built-in)
- **Fedora/RHEL:** dnf (built-in)
- **macOS:** Homebrew (will be installed if missing)

## Quick Install

### 1. Install Required Prerequisites

**Arch Linux:**
```bash
sudo pacman -S stow yq git python-pip
```

**Debian/Ubuntu:**
```bash
sudo apt-get update
sudo apt-get install stow yq git python3-pip
```

**Fedora/RHEL:**
```bash
sudo dnf install stow yq git python3-pip
```

**macOS:**
```bash
# Install Homebrew first if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Then install prerequisites
brew install stow yq git python3
```

### 2. Clone Repository

```bash
# Clone to a location of your choice
git clone <repository-url> ~/.local/share/dotfiles
cd ~/.local/share/dotfiles
```

### 3. Configure Machine Profile

Edit `config.yaml` to ensure your machine is configured:

```yaml
machines:
  - hostname: "your-hostname"  # Get with: hostname
    modules:
      - "terminal"      # Toolkit reference
      - "editors"       # Toolkit reference
      - "git"          # Direct module reference
```

If your hostname isn't in the config, add a new machine profile or use glob patterns:

```yaml
machines:
  - hostname: "laptop-*"  # Matches laptop-work, laptop-personal, etc.
    modules:
      - "minimal-server"
      - "editors"
```

### 4. Run Installer

```bash
./install.sh
```

The installer will:
1. Detect your OS and package manager
2. Auto-install prerequisites (cargo, paru) if missing
3. Discover available modules from directories
4. Collect dependencies from selected modules
5. Install all dependencies (packages, AUR, cargo, pip, scripts)
6. Verify installations
7. Stow configuration files to your home directory

### 5. Review Summary

The installer prints a summary showing:
- Modules stowed
- Packages installed
- Errors encountered
- Files backed up (if conflicts occurred)

Example output:
```
============================================================
                    Install Summary
============================================================

Modules stowed (15): bash fish zsh starship git tmux nvim ...
Native packages processed: 42
Cargo packages installed: 3
Pip packages installed: 5
Files backed up (2) to: ~/.dotfiles-backup/20260224-143022

Installation complete!
```

## Post-Installation

### Shell Configuration

If you installed shell modules (bash, zsh, fish), restart your shell or source the config:

```bash
# Bash
source ~/.bashrc

# Zsh
source ~/.zshrc

# Fish
source ~/.config/fish/config.fish
```

### Verify Installation

Check that installed tools are available:

```bash
# Check some common tools
which starship  # Should show path if starship module installed
which nvim      # Should show path if nvim module installed
git --version   # Should show version if git module installed
```

### Backup Files

If the installer encountered conflicting files, they were backed up to `~/.dotfiles-backup/<timestamp>/`. Review these files to see if you need to merge any custom configuration:

```bash
ls -la ~/.dotfiles-backup/
```

## Troubleshooting

### "No modules found for hostname"

**Problem:** Your hostname doesn't match any machine profile in `config.yaml`.

**Solution:** Add your hostname to `config.yaml`:

```bash
# Find your hostname
hostname

# Edit config.yaml and add a machine profile
```

### "Could not detect a supported package manager"

**Problem:** Your OS/distro isn't recognized.

**Solution:** The installer supports pacman, apt, dnf, yum, and brew. If you're on an unsupported system, you'll need to manually install prerequisites.

### "Module 'xyz' not found"

**Problem:** A module referenced in toolkits or machines doesn't have a corresponding directory or `deps.yaml`.

**Solution:** Either create the missing module or remove the reference from `config.yaml`.

### "cargo not found" or "pip not found"

**Problem:** Required language package managers are missing and couldn't be auto-installed.

**Solution:**
- **Cargo:** Install Rust: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- **Pip:** Install via your package manager: `sudo <pkg-mgr> install python3-pip`

### Stow Conflicts

**Problem:** Stow can't create symlinks because files already exist.

**Solution:** The installer automatically backs up conflicting files to `~/.dotfiles-backup/`. If you want to force clean re-stow:

```bash
# Manually remove existing config
rm ~/.config/nvim/init.lua

# Re-run installer
./install.sh
```

## Advanced Installation

### Installing Specific Modules Only

Temporarily modify your machine profile in `config.yaml` to include only desired modules:

```yaml
machines:
  - hostname: "test-system"
    modules:
      - "git"
      - "nvim"
      # Comment out others
```

### Custom Target Directories

Override where modules are stowed:

```yaml
machines:
  - hostname: "your-hostname"
    modules:
      - name: "wayvnc"
        target: "$HOME/.config"  # Instead of $HOME
```

### Installing on Systems Without Internet

1. Clone repository on a system with internet
2. Run installer once to cache dependencies
3. Copy the entire repository to offline system
4. Run installer (it will skip downloads for cached items)

Note: This has limitations - scripts that curl install commands will still fail.

### Multiple Machine Configurations

You can manage multiple machines from one repository:

```yaml
machines:
  - hostname: "work-laptop"
    modules: ["minimal-server", "python-dev"]

  - hostname: "home-desktop"
    modules: ["wayland-desktop", "cloud-native"]

  - hostname: "server-*"  # Matches multiple servers
    modules: ["minimal-server", "ssh"]
```

Clone the repository on each machine and run `./install.sh` - it will automatically select the right profile based on hostname.

## Updating Dotfiles

To update your dotfiles after making changes:

```bash
cd ~/.local/share/dotfiles

# Pull latest changes
git pull

# Re-run installer (idempotent - safe to run multiple times)
./install.sh
```

The installer is idempotent:
- Already-installed packages are skipped
- Already-stowed modules are re-stowed (updates symlinks)
- No duplicate installations occur

## Uninstalling

To remove dotfiles:

```bash
cd ~/.local/share/dotfiles

# Unstow all modules (removes symlinks)
for dir in */; do
    [ -f "$dir/deps.yaml" ] && stow -D "$dir"
done

# Optionally remove the repository
cd ~ && rm -rf ~/.local/share/dotfiles
```

Note: This doesn't uninstall packages, only removes configuration symlinks.

## Next Steps

- Learn how to [create new modules](module-creation.md)
- Understand the [deps.yaml format](deps-yaml-spec.md)
- Review [config.yaml specification](config-yaml-spec.md)
- Check [troubleshooting guide](troubleshooting.md) for common issues
