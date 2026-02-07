---
layout: default
title: "Keyboard Shortcuts"
nav_order: 10
---

# Keyboard Shortcuts Reference

Comprehensive keyboard shortcuts and keybindings for all modules.

{: .no_toc }

## Table of Contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Hyprland (Window Manager)

**Main Modifier Key**: `Super` (Windows key)

### Quick Reference Categories

- [Applications & System](#applications--system)
- [Window Focus & Navigation](#window-focus--navigation)
- [Window Positioning & Snapping](#window-positioning--snapping)
- [Window Resizing](#window-resizing)
- [Window Swapping & Rearranging](#window-swapping--rearranging)
- [Window States](#window-states)
- [Workspaces](#workspaces)
- [Layout Management](#layout-management)
- [Special Features](#special-features)
- [Mouse Bindings](#mouse-bindings)

---

## Window Focus & Navigation

Move focus between windows using arrow keys or vim-style keys.

| Keybinding | Alternative | Description |
|------------|-------------|-------------|
| `Super + ←` | `Super + H` | Move focus left |
| `Super + →` | - | Move focus right |
| `Super + ↑` | `Super + K` | Move focus up |
| `Super + ↓` | - | Move focus down |

**Note**: `Super + L` is reserved for Lock screen. Use arrow keys for right focus navigation.

---

## Window Positioning & Snapping

Snap windows to specific screen positions. Windows automatically become floating.

### Half Screen Snapping

| Keybinding | Alternative | Description |
|------------|-------------|-------------|
| `Super + Ctrl + ←` | `Super + Ctrl + H` | Snap to left half |
| `Super + Ctrl + →` | `Super + Ctrl + L` | Snap to right half |
| `Super + Ctrl + ↑` | `Super + Ctrl + K` | Snap to top half |
| `Super + Ctrl + ↓` | `Super + Ctrl + J` | Snap to bottom half |

### Quarter Screen Snapping (Corners)

| Keybinding | Description |
|------------|-------------|
| `Super + Ctrl + U` | Snap to top-left corner |
| `Super + Ctrl + I` | Snap to top-right corner |
| `Super + Ctrl + N` | Snap to bottom-left corner |
| `Super + Ctrl + M` | Snap to bottom-right corner |

### Center Window

| Keybinding | Description |
|------------|-------------|
| `Super + Ctrl + C` | Center window (60% width, 70% height) |

---

## Window Resizing

### Quick Resize (40px steps)

| Keybinding | Alternative | Description |
|------------|-------------|-------------|
| `Super + Alt + ←` | `Super + Alt + H` | Shrink width (left edge) |
| `Super + Alt + →` | `Super + Alt + L` | Grow width (right edge) |
| `Super + Alt + ↑` | `Super + Alt + K` | Shrink height (top edge) |
| `Super + Alt + ↓` | `Super + Alt + J` | Grow height (bottom edge) |

### Fine-Tuning Resize Mode (10px steps)

| Keybinding | Description |
|------------|-------------|
| `Super + Alt + R` | Enter resize mode |
| `Arrow Keys` or `H/J/K/L` | Resize in direction (while in resize mode) |
| `Esc` or `Enter` | Exit resize mode |

---

## Window Swapping & Rearranging

Swap window positions in tiled layout without changing focus.

| Keybinding | Alternative | Description |
|------------|-------------|-------------|
| `Super + Shift + ←` | `Super + Shift + H` | Swap with left window |
| `Super + Shift + →` | `Super + Shift + L` | Swap with right window |
| `Super + Shift + ↑` | `Super + Shift + K` | Swap with upper window |
| `Super + Shift + ↓` | - | Swap with lower window |

---

## Window States

### Floating Window Movement (40px steps)

Move floating windows with keyboard.

| Keybinding | Alternative | Description |
|------------|-------------|-------------|
| `Super + Ctrl + Shift + ←` | `Super + Ctrl + Shift + H` | Move left |
| `Super + Ctrl + Shift + →` | `Super + Ctrl + Shift + L` | Move right |
| `Super + Ctrl + Shift + ↑` | `Super + Ctrl + Shift + K` | Move up |
| `Super + Ctrl + Shift + ↓` | `Super + Ctrl + Shift + J` | Move down |

### Window State Controls

| Keybinding | Description |
|------------|-------------|
| `Super + V` | Toggle floating mode |
| `Super + F` | Toggle fullscreen |
| `Super + Z` | Minimize (move to special workspace) |
| `Super + Shift + Z` | Show/toggle minimized windows |
| `Super + Ctrl + P` | Pin window (show on all workspaces) |
| `Super + J` | Toggle split direction (dwindle) |
| `Super + Shift + T` | Toggle pseudo-tiling |

---

## Workspaces

Switch between and move windows to workspaces 1-9.

### Switch to Workspace

| Keybinding | Description |
|------------|-------------|
| `Super + 1` to `Super + 9` | Switch to workspace 1-9 |
| `Super + S` | Toggle special workspace |

### Move Window to Workspace

| Keybinding | Description |
|------------|-------------|
| `Super + Shift + 1` to `Super + Shift + 9` | Move active window to workspace 1-9 |

### Workspace Navigation

| Keybinding | Description |
|------------|-------------|
| `Super + Mouse Wheel` | Cycle through workspaces |
| `Super + Ctrl + ←/→` | Switch to adjacent workspace |

---

## Layout Management

Control tiling layouts and window arrangements.

### Layout Switching

| Keybinding | Description |
|------------|-------------|
| `Super + O` | Toggle between dwindle and master layouts |

### Dwindle Layout Controls

| Keybinding | Description |
|------------|-------------|
| `Super + B` | Preselect split left (next window opens on left) |
| `Super + A` | Preselect split right (next window opens on right) |
| `Super + J` | Toggle split direction |

### Master Layout Controls

| Keybinding | Description |
|------------|-------------|
| `Super + Shift + O` | Cycle master orientation (left/top) |
| `Super + Ctrl + Enter` | Swap active window with master |

---

## Applications & System

### Launch Applications

| Keybinding | Description |
|------------|-------------|
| `Super + Return` | Open terminal (kitty) |
| `Super + B` | Open browser (Firefox) |
| `Super + E` | Open file manager (dolphin) |
| `Super + R` | Open application launcher (rofi) |
| `Super + P` | Open 1Password quick access |
| `Super + W` | Close active window |
| `Super + L` | Lock screen (hyprlock) |
| `Super + M` | Exit/logout Hyprland |

### System Actions (Super + Shift)

| Keybinding | Description |
|------------|-------------|
| `Super + Shift + S` | Screenshot area to clipboard |
| `Super + Shift + P` | Screenshot area to file (Pictures/) |
| `Super + Shift + R` | Reload Hyprland configuration |
| `Super + Shift + E` | Exit Hyprland |

### Advanced Actions (Super + Alt)

| Keybinding | Description |
|------------|-------------|
| `Super + Alt + T` | Open task manager (htop) |
| `Super + Alt + Return` | Open browser (alternate binding) |

---

## Special Features

### Screenshots

| Keybinding | Description |
|------------|-------------|
| `Super + Shift + S` | Screenshot area to clipboard |
| `Super + Shift + P` | Screenshot area to file (Pictures/Screenshots/) |
| `Print` | Screenshot area to clipboard (alternate) |
| `Shift + Print` | Screenshot area to file (alternate) |

### Multimedia Controls

| Keybinding | Description |
|------------|-------------|
| `XF86AudioRaiseVolume` | Increase volume 5% |
| `XF86AudioLowerVolume` | Decrease volume 5% |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle microphone mute |
| `XF86MonBrightnessUp` | Increase brightness |
| `XF86MonBrightnessDown` | Decrease brightness |
| `XF86AudioNext` | Next track (playerctl) |
| `XF86AudioPrev` | Previous track (playerctl) |
| `XF86AudioPlay/Pause` | Play/pause media (playerctl) |

---

## Mouse Bindings

| Keybinding | Description |
|------------|-------------|
| `Super + Left Click Drag` | Move window |
| `Super + Right Click Drag` | Resize window |

---

## Modifier Key Logic

Understanding the modifier key combinations:

- **`Super`** = Basic actions (focus, launch apps)
- **`Super + Shift`** = Move/transfer (swap windows, move to workspace)
- **`Super + Ctrl`** = Position/snap (control window placement)
- **`Super + Alt`** = Resize (dimension control)
- **`Super + Ctrl + Shift`** = Precise floating movement (maximum control)

---

## Tips

1. **Vim Keys vs Arrow Keys**: Most shortcuts support both vim-style (H/J/K/L) and arrow keys for your preference.

2. **Resize Mode**: Use `Super + Alt + R` to enter resize mode for precise adjustments without holding modifiers.

3. **Window Snapping**: Snapped windows automatically become floating. Use `Super + V` to return to tiling.

4. **Minimize Workflow**: Minimized windows go to a special workspace. Toggle with `Super + Shift + Z` to see all minimized windows.

5. **Layout Experimentation**: Try both dwindle and master layouts (`Super + O`) to find which works better for your workflow.

6. **Multi-Monitor**: Window snapping scripts are monitor-aware and work correctly with multiple displays.

7. **Mnemonic Keybindings**: Application shortcuts use intuitive letter mappings: B for Browser, E for Explorer, P for Password, R for Run/Rofi, W for Window close, L for Lock. This makes them easy to remember and quick to access.

---

## Other Module Shortcuts

### Kitty Terminal

See [Kitty Module Documentation](modules/kitty.md) for terminal-specific keybindings.

### Rofi Launcher

See [Rofi Module Documentation](modules/rofi.md) for launcher shortcuts.

### Git Aliases

See [Git Module Documentation](modules/git.md) for git command aliases and shortcuts.

---

## Adding Module Shortcuts

When adding new modules with keybindings:

1. Document shortcuts in the module's documentation (`docs/modules/<module>.md`)
2. Add a reference section here linking to that documentation
3. For complex keybinding sets, create a dedicated section in this file

---

**Configuration Location**: `~/.config/hypr/hyprland.conf`  
**Helper Scripts**: `~/.config/hypr/scripts/`  
**Last Updated**: 2026-02-06
