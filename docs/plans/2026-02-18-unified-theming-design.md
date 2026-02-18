# Unified Tokyo Night Theming Design

**Date:** 2026-02-18
**Status:** Approved
**Scope:** Unify Tokyo Night theme across entire Hyprland desktop ecosystem

## Problem

The dotfiles repository has a Tokyo Night color palette applied across kitty, starship, rofi, hyprlock, tmux, and neovim, but several inconsistencies and gaps exist:

- Hyprland window borders use off-palette colors (`#33ccff`, `#00ff99`) instead of Tokyo Night palette
- Waybar has zero configuration — runs system defaults
- No GTK, QT, or cursor theme management
- No SDDM login screen theming
- No wallpaper management (hyprpaper)
- No notification daemon configuration (swaync)

## Tokyo Night Palette Reference

All tools must use these colors consistently:

| Name       | Hex       | Role                                      |
|------------|-----------|-------------------------------------------|
| night      | `#1a1b26` | Primary background (darkest)              |
| storm      | `#24283b` | Secondary background (panels, pills, bars)|
| bg_hover   | `#292e42` | Hover/highlight background                |
| fg         | `#c0caf5` | Primary foreground text                   |
| fg_dim     | `#a9b1d6` | Secondary/dimmed text                     |
| comment    | `#565f89` | Muted text, borders, inactive elements    |
| selection  | `#33467c` | Selection highlight background            |
| red        | `#f7768e` | Errors, urgent, destructive               |
| orange     | `#ff9e64` | Warnings, attention                       |
| yellow     | `#e0af68` | Caution, git status                       |
| green      | `#9ece6a` | Success, active                           |
| teal       | `#73daca` | Info, bright cyan-green                   |
| blue       | `#7aa2f7` | Primary accent (active borders, focus)    |
| cyan       | `#7dcfff` | Links, bright cyan                        |
| magenta    | `#bb9af7` | Secondary accent, alternate highlights    |

## Design Decisions

### 1. Hyprland Border Fix

Replace off-palette gradient with Tokyo Night colors:

```
# Before
col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg

# After
col.active_border = rgba(7aa2f7ee) rgba(bb9af7ee) 45deg
col.inactive_border = rgba(565f89aa)
```

**Files modified:** `hyprland/.config/hypr/hyprland.conf`

### 2. Waybar (New Module)

New `waybar/` stow module with floating pill design.

**Style:**
- Floating pill modules — individual rounded capsules with gaps between them
- Transparent bar background (no continuous bar)
- 8px margin from top edge and sides
- Pill backgrounds: `#24283b` at 85% opacity, 20px border radius
- Hover: background lightens to `#292e42`
- Smooth CSS transitions on hover
- Font: JetBrainsMono Nerd Font, 12px
- Icons: Nerd Font glyphs

**Layout:**

```
[LEFT]                                    [CENTER]        [RIGHT]
[Arch] [Clock] [Updates] [Media/Weather]  [Workspaces]   [Vol] [Net] [Bat] [Sys] [Notif] [Power]
```

**Left group (individual pills):**
1. Arch logo — static, accent blue icon
2. Clock — time display, tooltip shows full date
3. Updates — package count via checkupdates, tooltip shows package list
4. Media — playerctl artist/title, visible only when playing
5. Weather — wttrbar, temp + condition + location

**Center group:**
6. Workspaces — numbered pills, active highlighted with `#7aa2f7` bg

**Right group (individual pills):**
7. Volume — icon + percentage, scroll to adjust
8. Network — icon + name, tooltip shows IP address
9. Battery — icon + percentage, tooltip shows time remaining
10. System resources — single chip icon, click reveals popup with CPU/MEM/DISK/GPU/VRAM usage bars
11. Notification bell — swaync widget (do-not-disturb toggle)
12. Power button — click opens power menu (shutdown, reboot, logout, lock)

**Files created:**
- `waybar/.config/waybar/config.jsonc`
- `waybar/.config/waybar/style.css`
- `waybar/.config/waybar/scripts/sysinfo.sh`
- `waybar/.config/waybar/scripts/power-menu.sh`
- `waybar/deps.yaml`

### 3. GTK / QT / Cursor Theming (New Module)

New `theme/` stow module for desktop appearance settings.

**GTK:**
- Theme: `Tokyonight-Dark-BL` (AUR: `tokyonight-gtk-theme-git`)
- Icon theme: `Papirus-Dark`
- Font: `JetBrainsMono Nerd Font 10`
- Config files: `~/.config/gtk-3.0/settings.ini`, `~/.gtkrc-2.0`

**QT:**
- Style engine: `kvantum`
- Theme: Tokyo Night kvantum theme
- Config: `~/.config/qt5ct/qt5ct.conf`
- Env var: `QT_QPA_PLATFORMTHEME=qt5ct`

**Cursor:**
- Theme: `Bibata-Modern-Classic`
- Size: 24
- Config: `~/.icons/default/index.theme`

**Hyprland env additions:**
```
env = XCURSOR_THEME,Bibata-Modern-Classic
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORMTHEME,qt5ct
```

**Files created:**
- `theme/.config/gtk-3.0/settings.ini`
- `theme/.gtkrc-2.0`
- `theme/.config/qt5ct/qt5ct.conf`
- `theme/.config/Kvantum/kvantum.kvconfig`
- `theme/.icons/default/index.theme`
- `theme/deps.yaml`

### 4. SDDM Custom Theme

New `sddm/` stow module with custom minimal login theme.

**Design:**
- Minimal: username field, password field, clock, power/restart pill buttons only
- No user avatar, no session selector
- Background: solid `#1a1b26` or blurred wallpaper
- Input fields: `#24283b` bg, `#7aa2f7` border (2px), `#c0caf5` text
- Power/restart buttons: rounded pills matching waybar style (`#24283b` bg, `#7aa2f7` accent on hover)
- Clock: large, `#c0caf5` text, JetBrainsMono Nerd Font
- Font: JetBrainsMono Nerd Font throughout

**Files created:**
- `sddm/theme/tokyonight-minimal/` (QML theme files)
- `sddm/scripts/install-sddm-theme.sh` (sudo installer)
- `sddm/deps.yaml`

### 5. Hypridle Update

Remove all auto-lock and DPMS timeouts. Lock only via intentional keybind.

```
# Remove:
# - 300s lock timeout
# - 330s DPMS timeout
# Keep hypridle running but with no active listeners
```

**Files modified:** `hyprland/.config/hypr/hypridle.conf`

### 6. Hyprpaper + Wallpaper

New wallpaper management via hyprpaper.

**Wallpaper:** Purple cityscape with train (`wallpapers/tokyonight.jpg`) — Unsplash, free license.

**Hyprpaper config:**
```
preload = ~/.local/share/dotfiles/wallpapers/tokyonight.jpg
wallpaper = ,~/.local/share/dotfiles/wallpapers/tokyonight.jpg
splash = false
```

**Files created/modified:**
- `wallpapers/tokyonight.jpg` (already downloaded)
- `hyprland/.config/hypr/hyprpaper.conf` (new)
- Update `hyprland.conf` exec-once to include `hyprpaper`

### 7. Swaync Notification Daemon

Configure swaync as the notification daemon with Tokyo Night theming.

**Style:**
- Notification background: `#24283b`
- Notification border: `#7aa2f7`
- Text: `#c0caf5`
- Urgent: `#f7768e` border
- Font: JetBrainsMono Nerd Font
- Border radius: 10px (matching hyprland window rounding)

**Files created:**
- `swaync/.config/swaync/config.json`
- `swaync/.config/swaync/style.css`
- `swaync/deps.yaml`

## Module Summary

| Module   | Status     | Action                                    |
|----------|------------|-------------------------------------------|
| hyprland | Existing   | Fix border colors, add env vars, hyprpaper|
| waybar   | **New**    | Full config + CSS + scripts               |
| theme    | **New**    | GTK/QT/cursor configs                     |
| sddm     | **New**    | Custom QML login theme                    |
| swaync   | **New**    | Notification daemon config                |
| kitty    | Existing   | No changes needed                         |
| starship | Existing   | No changes needed                         |
| rofi     | Existing   | No changes needed                         |
| tmux     | Existing   | No changes needed                         |
| nvim     | Existing   | No changes needed                         |

## Config.yaml Updates

Add new modules to `config.yaml`:
- `waybar`
- `theme`
- `sddm`
- `swaync`

## Dependencies to Install

New system packages required:
- `waybar` (already in hyprland deps)
- `swaync` (AUR: `swaync`)
- `wttrbar` (AUR: `wttrbar`)
- `playerctl`
- `hyprpaper`
- `kvantum` / `qt5ct`
- `tokyonight-gtk-theme-git` (AUR)
- `papirus-icon-theme`
- `bibata-cursor-theme` (AUR)
- `sddm`

## Out of Scope (Future Work)

- Template engine for theme switching (full palette swap across all tools)
- Multiple theme definitions (Catppuccin Mocha, Gruvbox, Nord)
- CLI `theme-switch` command + rofi theme picker
- Per-monitor wallpaper configuration
