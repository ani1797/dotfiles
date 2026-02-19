# Yazi File Manager Module Design

**Date:** 2026-02-19
**Status:** Approved
**Scope:** Create a yazi dotfiles module with Tokyo Night theming and sensible defaults

## Overview

Add a yazi terminal file manager module to the dotfiles repository, following existing stow patterns. Yazi is a blazing-fast async file manager written in Rust with built-in image preview, code highlighting, and plugin support.

## Module Structure

```
yazi/
├── .config/yazi/
│   ├── yazi.toml      # Main config (layout, openers, sorting, preview)
│   ├── keymap.toml    # Custom keybindings (prepend to defaults)
│   ├── theme.toml     # Tokyo Night cyberpunk theme
│   └── init.lua       # Plugin initialization (git status)
└── .stow-local-ignore
```

Deploys to `~/.config/yazi/` via stow.

## Tokyo Night Palette Reference

Consistent with existing modules (kitty, starship, rofi, waybar, etc.):

| Name      | Hex       | Yazi Role                          |
|-----------|-----------|------------------------------------|
| night     | `#1a1b26` | Primary background                 |
| storm     | `#24283b` | Secondary bg (borders, tabs)       |
| bg_hover  | `#292e42` | Hover/highlight background         |
| fg        | `#c0caf5` | Primary foreground text            |
| fg_dim    | `#a9b1d6` | Secondary/dimmed text              |
| comment   | `#565f89` | Muted text, borders, inactive      |
| selection | `#33467c` | Selection highlight                |
| red       | `#f7768e` | Errors, cut markers, archives      |
| orange    | `#ff9e64` | Warnings                           |
| yellow    | `#e0af68` | Images, permissions read           |
| green     | `#9ece6a` | Success, selected markers, exec    |
| teal      | `#73daca` | Info                               |
| blue      | `#7aa2f7` | Primary accent, directories, CWD   |
| cyan      | `#7dcfff` | Links, symlinks                    |
| magenta   | `#bb9af7` | Media files, secondary accent      |

## Configuration Details

### yazi.toml
- Ratio: 1:4:3 (parent:current:preview)
- Natural sorting, directories first, case-insensitive
- Show symlinks, hidden files off by default
- Image/PDF/video/archive preview enabled
- Platform-appropriate openers ($EDITOR, xdg-open/open)
- Scrolloff of 5 for comfortable browsing

### theme.toml
- Full Tokyo Night palette applied to all UI elements
- Status bar with powerline separators (matching starship style)
- File type coloring: dirs blue, images yellow, media magenta, archives red
- Permission coloring: read yellow, write red, exec green

### keymap.toml
- Prepend-only (preserves all yazi defaults)
- Shell spawn in cwd
- Archive extraction shortcut
- Zoxide jump integration

### init.lua
- Git status integration (built-in `git` plugin setup)

## Hosts

All hosts: HOME-DESKTOP, ASUS-LAPTOP, WORK-MACBOOK, CODESPACES, asus-vivobook, DESKTOP-OKTKL4S

## Dependencies

Required: `yazi` (installed separately)

Optional (for preview features): `ffmpeg`, `7zip`, `poppler`, `fd`, `ripgrep`, `fzf`, `zoxide`, `imagemagick`, `resvg`

Config works without optional deps; previews gracefully degrade.
