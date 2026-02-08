---
layout: default
title: "Tmux Configuration"
parent: Modules
---

# Tmux Module

Terminal multiplexer configuration with Ctrl+Space prefix, Tokyo Night theme, and TPM plugin manager.

## Overview

This module provides a configured tmux setup including:
- Ctrl+Space as the prefix key
- Intuitive split and navigation keybindings
- Tokyo Night status bar theme
- Vi copy-mode with system clipboard integration
- TPM (Tmux Plugin Manager) for plugin management
- Session persistence with tmux-resurrect

## What's Included

### Configuration Files

- **`tmux.conf`** - Main tmux configuration
  - Prefix key: Ctrl+Space
  - Mouse support enabled
  - 1-based window/pane indexing
  - 256-color and truecolor terminal support
  - Vi copy-mode with wl-copy integration
  - Tokyo Night status bar styling
  - TPM plugin declarations

### Utility Scripts

- **`configure-tmux`** - Bootstrap script
  - Checks tmux version (warns if <3.1 for XDG support)
  - Installs TPM (Tmux Plugin Manager)
  - Installs declared plugins non-interactively
  - Prints keybinding reference

## Keybindings

### Prefix & Basics

| Keybinding | Description |
|------------|-------------|
| `Ctrl+Space` | Prefix key |
| `prefix + c` | New window (current path) |
| `prefix + r` | Reload config |
| `prefix + m` | Edit config in nvim |
| `prefix + b` | Toggle status bar |

### Splits

| Keybinding | Description |
|------------|-------------|
| `prefix + \` | Horizontal split (current path) |
| `prefix + -` | Vertical split (current path) |

### Pane Navigation

| Keybinding | Description |
|------------|-------------|
| `Alt+Left` | Select pane left (no prefix) |
| `Alt+Right` | Select pane right (no prefix) |
| `Alt+Up` | Select pane up (no prefix) |
| `Alt+Down` | Select pane down (no prefix) |

### Window Navigation

| Keybinding | Description |
|------------|-------------|
| `Ctrl+Alt+Left` | Previous window |
| `Ctrl+Alt+Right` | Next window |

### Session Management

| Keybinding | Description |
|------------|-------------|
| `prefix + k` | Kill window (with confirmation) |
| `prefix + K` | Kill server (with confirmation) |
| `prefix + End` | Kill pane |

### Vi Copy Mode

| Keybinding | Description |
|------------|-------------|
| `v` | Begin selection |
| `y` | Copy selection to clipboard |
| `r` | Toggle rectangle selection |

### TPM Plugins

| Keybinding | Description |
|------------|-------------|
| `prefix + I` | Install plugins |
| `prefix + U` | Update plugins |
| `prefix + Ctrl+s` | Save session (resurrect) |
| `prefix + Ctrl+r` | Restore session (resurrect) |

## Installation

### Prerequisites

Tmux 3.1+ is recommended (for XDG config directory support):

```bash
# Arch Linux
sudo pacman -S tmux

# Debian/Ubuntu
sudo apt-get install tmux

# macOS
brew install tmux
```

### Deployment

This module is deployed via the main `install.sh` script:

```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh
```

After deployment, install plugins:

```bash
configure-tmux
```

### Older Tmux Versions

If your tmux version is below 3.1, it doesn't support `~/.config/tmux/tmux.conf` natively. Create a symlink:

```bash
ln -s ~/.config/tmux/tmux.conf ~/.tmux.conf
```

## Included Plugins

| Plugin | Description |
|--------|-------------|
| tmux-sensible | Sensible default settings |
| tmux-resurrect | Save and restore sessions across restarts |

## Module Configuration

Deployed to hosts: `HOME-DESKTOP`, `ASUS-LAPTOP`, `WORK-MACBOOK`, `CODESPACES`

Module structure:
```
tmux/
├── .config/tmux/
│   └── tmux.conf
├── .local/bin/
│   └── configure-tmux
└── .stow-local-ignore
```
