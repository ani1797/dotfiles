---
layout: default
title: "Neovim Configuration"
parent: Modules
---

# Neovim Module

Modern Neovim configuration with Lazy.nvim plugin manager, modular plugin architecture, and Tokyo Night theme.

## Overview

This module provides a fully configured Neovim setup including:
- Lazy.nvim plugin manager with automatic bootstrapping
- Modular plugin architecture (delete a file to disable a feature)
- Tokyo Night colorscheme
- Telescope fuzzy finder
- Neo-tree file explorer
- Treesitter syntax highlighting
- LSP support with Mason for automatic server installation
- nvim-cmp completion engine
- Avante AI/Claude integration

## What's Included

### Plugin Files

Each plugin is a standalone file in `lua/plugins/`. Delete any file to disable that feature.

- **`tokyonight.lua`** - Tokyo Night colorscheme (night variant)
- **`telescope.lua`** - Fuzzy finder for files, grep, buffers, and help
- **`neotree.lua`** - File explorer sidebar with LSP file operations
- **`treesitter.lua`** - Advanced syntax highlighting and code parsing
- **`lsp.lua`** - Language Server Protocol support
  - Mason for automatic LSP server installation
  - mason-lspconfig for seamless integration
  - Pre-configured servers: lua_ls, pyright, ts_ls, rust_analyzer, gopls, bashls
  - Works with or without completion.lua (uses `pcall` for cmp integration)
- **`completion.lua`** - Auto-completion engine
  - nvim-cmp with buffer, path, LSP, and snippet sources
  - LuaSnip snippet engine
  - Tab/Shift-Tab navigation
  - Works with or without LSP
- **`avante.lua`** - AI/Claude integration
  - Claude as the default provider
  - Completely independent (VeryLazy loaded)
  - Delete this file to disable AI features

### Configuration Files

- **`init.lua`** - Entry point, loads lazy.lua and sets editor defaults
- **`lua/config/lazy.lua`** - Bootstraps Lazy.nvim, sets leader key to Space

### Utility Scripts

- **`configure-nvim`** - Bootstrap script that syncs all plugins headlessly

## Keybindings

### Telescope (Fuzzy Finder)

| Keybinding | Description |
|------------|-------------|
| `Ctrl+f` | Find files |
| `Ctrl+l` | Live grep |
| `Space+ff` | Find files (alt) |
| `Space+fg` | Live grep (alt) |
| `Space+fb` | Buffers |
| `Space+fh` | Help tags |

### Neo-tree (File Explorer)

| Keybinding | Description |
|------------|-------------|
| `Ctrl+n` | Toggle file explorer |

### LSP

| Keybinding | Description |
|------------|-------------|
| `gd` | Go to definition |
| `K` | Hover documentation |
| `gi` | Go to implementation |
| `Ctrl+k` | Signature help |
| `gr` | References |
| `Space+rn` | Rename symbol |
| `Space+ca` | Code action |

### Completion (nvim-cmp)

| Keybinding | Description |
|------------|-------------|
| `Ctrl+Space` | Trigger completion |
| `CR` (Enter) | Confirm selection |
| `Tab` | Next item / expand snippet |
| `Shift+Tab` | Previous item |
| `Ctrl+b` | Scroll docs up |
| `Ctrl+f` | Scroll docs down |
| `Ctrl+e` | Abort completion |

### Avante (AI/Claude)

| Keybinding | Description |
|------------|-------------|
| `Space+aa` | Ask AI |
| `Space+ae` | Edit with AI |
| `Space+ar` | Refresh AI |

## Installation

### Prerequisites

Neovim 0.9+ must be installed:

```bash
# Arch Linux
sudo pacman -S neovim

# Debian/Ubuntu
sudo apt-get install neovim

# macOS
brew install neovim
```

### Deployment

This module is deployed via the main `install.sh` script:

```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh
```

After deployment, bootstrap plugins:

```bash
configure-nvim
```

This runs `nvim --headless "+Lazy! sync" +qa` to install all plugins.

### Managing Plugins

- `:Lazy` — Open Lazy.nvim UI (sync, update, clean)
- `:Mason` — Manage LSP servers
- `:TSUpdate` — Update Treesitter parsers

## Modularity

The plugin architecture is fully modular. To disable a feature, delete its file from `~/.config/nvim/lua/plugins/`:

```bash
# Disable AI features
rm ~/.config/nvim/lua/plugins/avante.lua

# Disable completion (LSP still works)
rm ~/.config/nvim/lua/plugins/completion.lua

# Disable file explorer
rm ~/.config/nvim/lua/plugins/neotree.lua
```

LSP and completion are designed to work independently — lsp.lua uses `pcall` to optionally integrate with cmp if present.

## Module Configuration

Deployed to hosts: `HOME-DESKTOP`, `ASUS-LAPTOP`, `WORK-MACBOOK`, `CODESPACES`

Module structure:
```
nvim/
├── .config/nvim/
│   ├── init.lua
│   └── lua/
│       ├── config/
│       │   └── lazy.lua
│       └── plugins/
│           ├── tokyonight.lua
│           ├── telescope.lua
│           ├── neotree.lua
│           ├── treesitter.lua
│           ├── lsp.lua
│           ├── completion.lua
│           └── avante.lua
├── .local/bin/
│   └── configure-nvim
└── .stow-local-ignore
```
