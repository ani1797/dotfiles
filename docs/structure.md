---
layout: default
title: "Repository Structure"
---

# Repository Structure

Each module resides in its own directory under the root of the repository. The directories contain dotfiles that GNU Stow deploys into your home (or specified target) directories via symlinks.

## Module Overview

### Shell Configuration

| Module | Description |
|--------|-------------|
| **[bash](modules/bash)** | Bash configuration (`.bashrc`, aliases, environment) |
| **[zsh](modules/zsh)** | Zsh configuration with plugins, aliases, and Starship prompt |
| **[fish](modules/fish)** | Fish shell with Fisher plugins, aliases, and Starship prompt |
| **[starship](modules/starship)** | Unified Starship prompt — cyberpunk Tokyo Night theme |
| **[shell-utils](modules/shell-utils)** | Shared shell utilities (helper scripts used across shells) |

### Development Tools

| Module | Description |
|--------|-------------|
| **[git](modules/git)** | Git configuration with SSH-based commit signing, 30+ aliases |
| **[nvim](modules/nvim)** | Neovim with Lazy.nvim, LSP, Telescope, and Tokyo Night theme |
| **[vim](modules/vim)** | Vim configuration (`.vimrc`) for systems without Neovim |
| **[tmux](modules/tmux)** | Tmux with Ctrl+Space prefix, Tokyo Night status bar, TPM |
| **[direnv](modules/direnv)** | Directory-level environment variables with 1Password integration |
| **[ssh](modules/ssh)** | Structured SSH config with `Include config.d/*` and 1Password agent |

### Desktop Environment

| Module | Description |
|--------|-------------|
| **[hyprland](modules/hyprland)** | Hyprland tiling Wayland compositor |
| **[kitty](modules/kitty)** | GPU-accelerated terminal — cyberpunk Tokyo Night theme, JetBrainsMono |
| **[rofi](modules/rofi)** | Application launcher and menu system |
| **[wayvnc](modules/wayvnc)** | VNC server for Wayland compositors |
| **[fonts](modules/fonts)** | Font packages (JetBrainsMono Nerd Font, etc.) |

### Package Managers & Runtimes

| Module | Description |
|--------|-------------|
| **[npm](modules/npm)** | npm registry and configuration (`.npmrc`) |
| **[pip](modules/pip)** | pip configuration (`pip.conf`) |
| **[uv](modules/uv)** | uv Python package manager configuration |
| **[podman](modules/podman)** | Podman container registries and configuration |

### Other

| Module | Description |
|--------|-------------|
| **[antigravity](modules/antigravity)** | Antigravity application configuration |

## Module Directory Convention

Each module follows a consistent structure:

```
module-name/
├── .config/              # XDG config files → ~/.config/
├── .local/               # User-local files → ~/.local/
│   └── bin/              # Executable scripts
├── .stow-local-ignore    # Files excluded from stow deployment
├── deps.yaml             # Module dependencies (packages to install)
└── [dotfiles]            # Files deployed directly to $HOME
```

## Key Repository Files

| File | Purpose |
|------|---------|
| `config.yaml` | Defines which modules to deploy and for which hosts |
| `install.sh` | GNU Stow deployment script |
| `bootstrap.sh` | Automated setup for fresh systems |
| `CLAUDE.md` | Instructions for Claude Code AI assistant |
