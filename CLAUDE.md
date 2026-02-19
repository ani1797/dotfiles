# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository that uses GNU Stow for managing configuration files. The repository contains configuration files for various shells and editors, organized into modules that can be deployed to a user's home directory or work directory.

## Key Components

- **install.sh**: Unified installer that self-bootstraps, reads config.yaml, installs per-module dependencies from deps.yaml, backs up conflicts, and stows modules
- **config.yaml**: Configuration file with two top-level keys: `modules[]` (module definitions) and `machines[]` (hostname-to-module mappings)
- **deps.yaml**: Per-module dependency manifests (placed inside each module directory) declaring native packages, cargo crates, pip packages, and install scripts
- **Module directories**:
  - `bash/` - Contains Bash configuration files (e.g., .bashrc)
  - `zsh/` - Contains Zsh configuration files (e.g., .zshrc)
  - `fish/` - Contains Fish shell configuration files
  - `starship/` - Unified prompt config (cyberpunk Tokyo Night theme)
  - `kitty/` - GPU-accelerated terminal emulator config
  - `git/` - Git configuration with SSH signing
  - `vim/` - Contains Vim configuration files (e.g., .vimrc)
  - `nvim/` - Neovim configuration with Lazy.nvim
  - `direnv/` - Environment variable management
  - `hyprland/` - Wayland compositor configuration
  - `tmux/` - Terminal multiplexer configuration
  - `ssh/` - SSH configuration
  - `rofi/` - Application launcher
  - `wayvnc/` - VNC server for Wayland
  - And more: `fonts/`, `npm/`, `pip/`, `podman/`, `uv/`, `shell-utils/`, `antigravity/`

## Shell Utilities

- **`~dot` / `dot`**: Quick navigation to `~/.local/share/dotfiles`. In zsh, `~dot` expands everywhere (named directory). In bash/fish, use `$DOT` or the `dot` alias.
- **`set_env KEY VALUE`**: Sets a temporary environment variable in the current shell session. Works in bash, zsh, and fish.

## Installation Process

To install the dotfiles, just run:
```bash
./install.sh
```

The script is the single entrypoint for setup. It performs the following steps:
1. **Self-bootstraps** -- detects the distro and package manager, then installs `stow` and `yq` automatically if they are missing (supports pacman, apt, dnf, and brew)
2. **Matches the current hostname** against `machines[]` in config.yaml to determine which modules to install
3. **Installs per-module dependencies** from each module's `deps.yaml` (native packages, cargo crates, pip packages, and install scripts)
4. **Backs up conflicting files** -- any real (non-symlink) files that would conflict with stow are moved to `~/.dotfiles-backup/<timestamp>/` before linking
5. **Stows modules** using `stow --restow --no-folding`, which also cleans up dead symlinks from previously removed files

The installer is idempotent and safe to run repeatedly.

## Config Schema (config.yaml)

config.yaml has two top-level keys: `modules` and `machines`.

### modules[]
Defines every available module. Each entry has a `name`, a `path` (directory in this repo), and an optional `target` (defaults to `$HOME`):
```yaml
modules:
  - name: "bash"
    path: "bash"
  - name: "app-config"
    path: "app"
    target: "/opt/myapp"   # optional module-level target override
```

### machines[]
Each machine entry has a `hostname` (matched against `$(hostname)`) and a list of modules to install. Module references are either a plain string (module name) or an object with `name` + `target` override:
```yaml
machines:
  - hostname: "HOME-DESKTOP"
    modules:
      - "bash"               # plain string: uses module default target
      - "app-config"
      - name: "vim"          # object form: override target for this machine
        target: "$HOME/.work"

  - hostname: "WORK-MACBOOK"
    modules:
      - "bash"
      - "vim"
```

Target resolution priority: machine-level override > module-level default > `$HOME`. Target values can use environment variables (e.g., `$HOME`) which are expanded at runtime.

## Module Dependencies (deps.yaml)

Each module directory may contain a `deps.yaml` file declaring its dependencies. The installer reads this file and installs dependencies before stowing. The format supports multiple sources:

```yaml
# Native packages, keyed by distro family
packages:
  arch:
    - git
  debian:
    - git
  fedora:
    - git
  macos:
    - git

# Cargo crates (installed via cargo install, skipped if already present)
cargo:
  - yazi-fm

# Pip packages (installed with pip install --user)
pip:
  - some-tool

# Install scripts with optional idempotency guard
script:
  - run: "curl -sS https://starship.rs/install.sh | sh -s -- --yes"
    provides: starship   # skip if this binary is already on $PATH
```

All sections are optional. The `packages` key maps distro families (`arch`, `debian`, `fedora`, `macos`) to the corresponding native package names.

## Development Workflow

This repository is designed for managing personal configuration files. The main development task would involve:
1. Adding or modifying dotfiles in their respective module directories
2. Updating config.yaml to include new modules or change host mappings
3. Running `./install.sh` to deploy changes

## Important Notes

- The installation process uses GNU Stow to create symbolic links (`stow --restow --no-folding`)
- install.sh self-bootstraps its own dependencies (`stow` and `yq`), so no manual pre-installation is needed
- The repository structure follows a modular approach for easy management of different configuration types
- Shell config files use a guard pattern (`[[ -n "${__<MODULE>_LOADED+x}" ]] && return`) to prevent double-sourcing