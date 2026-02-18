# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository that uses GNU Stow for managing configuration files. The repository contains configuration files for various shells and editors, organized into modules that can be deployed to a user's home directory or work directory.

## Key Components

- **install.sh**: The main installation script that reads config.yaml and uses GNU Stow to deploy dotfiles
- **config.yaml**: Configuration file that defines which modules to install and for which hosts
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

To install the dotfiles:
1. Ensure GNU Stow and yq are installed:
   - Debian/Ubuntu: `sudo apt-get install stow yq`
   - macOS with Homebrew: `brew install stow yq`
2. Run the installer: `./install.sh`
3. The script reads config.yaml, resolves module directories, and uses stow to link dotfiles into target directories
4. The config.yaml file allows you to individually select which modules to include for each system by specifying modules and their target hosts

## Host Configuration and Target Directories

The installer supports flexible target directory configuration:
- **Default target**: All modules deploy to `$HOME` by default
- **Module-level target**: Specify a `target` field at the module level to set a default for all hosts in that module
- **Host-level target**: Specify a `target` field for individual hosts to override the module default

Target directories can use environment variables (e.g., `$HOME`, `$USER`) which will be expanded at runtime.

Example configurations:
```yaml
# Simple: uses $HOME by default
- name: "bash"
  path: "bash"
  hosts:
    - local

# Module-level target
- name: "app-config"
  path: "app"
  target: "/opt/myapp"
  hosts:
    - local
    - work

# Host-level targets (overrides module default)
- name: "vim"
  path: "vim"
  hosts:
    - local  # Uses $HOME
    - name: work
      target: "$HOME/.work"
```

Each host can include a subset of modules as defined in config.yaml, allowing for different machine setups with different configurations.

## Development Workflow

This repository is designed for managing personal configuration files. The main development task would involve:
1. Adding or modifying dotfiles in their respective module directories
2. Updating config.yaml to include new modules or change host mappings
3. Running `./install.sh` to deploy changes

## Important Notes

- The installation process uses GNU Stow to create symbolic links
- The install.sh script is designed to be safe and will fail if required tools are missing
- The repository structure follows a modular approach for easy management of different configuration types