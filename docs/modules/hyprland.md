---
layout: default
title: "Hyprland Compositor"
parent: Modules
---

# Hyprland Configuration

Dynamic tiling Wayland compositor configuration with enhanced window management and Tokyo Night aesthetics.

**⚡ Quick Reference**: See [Keyboard Shortcuts](../keyboard-shortcuts.md) for complete keybindings and shortcuts.

## Features

### Window Management
- **Vim-style Navigation**: hjkl keys for focus movement
- **Smart Window Snapping**: Snap to halves, quarters, or center
- **Dual Layout Support**: Toggle between dwindle and master layouts
- **Resize Modes**: Quick resize (40px) and fine-tune mode (10px)
- **Window Pinning**: Pin windows across all workspaces
- **Special Workspaces**: Minimize windows to hidden workspace

### Visual Effects
- **Smooth Animations**: Custom bezier curves for fluid motion
- **Rounded Corners**: 10px rounding with power curve
- **Blur Effects**: Real-time blur on unfocused windows
- **Border Highlighting**: Gradient active borders (cyan to green)
- **Drop Shadows**: Subtle shadows for depth

### System Integration
- **Idle Management**: Auto-lock after 5 minutes, display off after 5.5 minutes (suspend disabled for SSH/VNC accessibility)
- **Lock Screen**: Tokyo Night themed hyprlock with blurred background
- **Screenshots**: Area selection with grim + slurp
- **Media Controls**: Volume, brightness, and playback bindings
- **Remote Desktop**: Secure VNC access via separate wayvnc module (see below)

## Documentation

- `keyshortcuts.md` - Comprehensive Hyprland keybinding reference (stowed to `~/.config/keyshortcuts.md`)

## Files

```
.config/hypr/
├── hyprland.conf       # Main configuration
├── hypridle.conf       # Idle/lock/suspend settings
├── hyprlock.conf       # Lock screen appearance
├── keyshortcuts.md     # Keybinding reference
└── scripts/
    ├── snap-window.sh      # Window snapping script
    └── switch-layout.sh    # Layout toggle script
```

## Dependencies

### Required
- `hyprland` - Wayland compositor
- `kitty` - Terminal emulator (configured as default)
- `rofi` - Application launcher
- `waybar` - Status bar
- `hyprpaper` - Wallpaper daemon
- `hypridle` - Idle management daemon
- `hyprlock` - Screen locker
- `jq` - JSON parser (for scripts)

### Optional
- `grim` + `slurp` - Screenshot tools
- `wl-clipboard` - Clipboard manager
- `wayvnc` - VNC server (configured via separate wayvnc module)
- `brightnessctl` - Brightness control
- `playerctl` - Media playback control
- `notify-send` - Desktop notifications

Install dependencies:
```bash
# Arch Linux
sudo pacman -S hyprland kitty rofi waybar hyprpaper hypridle hyprlock jq grim slurp wl-clipboard wayvnc brightnessctl playerctl libnotify

# Build from source (Hyprland)
# See: https://wiki.hypr.land/Getting-Started/Installation/
```

## Usage

### Starting Hyprland

From TTY:
```bash
Hyprland
```

With display manager: Select "Hyprland" session

### Basic Keybindings

`Super` = Windows/Command key

#### Applications
- `Super + Q` - Launch terminal
- `Super + R` - Application launcher (rofi)
- `Super + E` - File manager
- `Super + L` - Lock screen

#### Window Management
- `Super + C` - Close window
- `Super + V` - Toggle floating
- `Super + F` - Fullscreen
- `Super + Shift + F` - Maximize (keep gaps/bar)

#### Focus Navigation
- `Super + hjkl` or `Super + Arrows` - Move focus
- `Super + [1-9,0]` - Switch workspace
- `Super + Shift + [1-9,0]` - Move window to workspace

#### Window Snapping
- `Super + Ctrl + h/j/k/l` - Snap to left/bottom/top/right half
- `Super + Ctrl + u/i/n/m` - Snap to corners (topleft/topright/bottomleft/bottomright)
- `Super + Ctrl + c` - Center window (60% width, 70% height)

#### Window Resizing
- `Super + Alt + hjkl` - Resize by 40px
- `Super + Alt + r` - Enter fine-tune resize mode (10px steps, Escape to exit)

#### Layout Control
- `Super + o` - Toggle between dwindle and master layouts
- `Super + j` - Toggle split direction (dwindle)
- `Super + p` - Toggle pseudotile

#### Advanced
- `Super + Shift + hjkl` - Swap windows
- `Super + z` - Minimize (move to special workspace)
- `Super + Shift + z` - Show minimized windows
- `Super + Ctrl + p` - Pin window to all workspaces
- `Super + s` - Toggle scratchpad workspace

### Screenshots
- `Print` - Area screenshot to clipboard
- `Shift + Print` - Area screenshot to ~/Pictures/Screenshots/

### Reloading Configuration
- `Ctrl + Shift + F5` - Reload Hyprland config
- `Super + Shift + w` - Restart waybar

## Configuration Details

### Monitor Setup

Default configuration auto-detects monitors:
```conf
monitor=,preferred,auto,auto
```

For multi-monitor setups, edit `hyprland.conf`:
```conf
# Example: Two monitors side-by-side
monitor=DP-1,1920x1080@144,0x0,1
monitor=HDMI-A-1,1920x1080@60,1920x0,1

# List available monitors
hyprctl monitors
```

### Workspace Behavior

Default layout: `dwindle` (binary tree tiling)
Alternative: `master` (master-stack layout)

Toggle with `Super + o` or manually:
```bash
hyprctl keyword general:layout master
```

### Idle and Lock Settings

Configured in `hypridle.conf`:
- 5 minutes → Lock screen
- 5.5 minutes → Turn off display
- System suspend is **disabled** to maintain SSH/VNC accessibility

Adjust timeouts:
```conf
listener {
    timeout = 600  # Change to 10 minutes
    on-timeout = loginctl lock-session
}
```

### Autostart Applications

Edit `hyprland.conf` exec-once section:
```conf
exec-once = hyprpaper
exec-once = waybar
exec-once = hypridle
# Add more:
# exec-once = dunst        # Notification daemon
# exec-once = nm-applet    # Network manager
```

Additional autostart entries can be added via drop-in configs in `~/.config/hypr/conf.d/`. For example, the wayvnc module provides `conf.d/wayvnc.conf` which is sourced automatically.

### Remote Desktop Access

WayVNC is started via a drop-in config (`~/.config/hypr/conf.d/wayvnc.conf`) that runs `start-wayvnc` through Hyprland's `exec-once`. The script runs wayvnc as root via sudo for PAM authentication.

**Setup steps**:
1. Deploy the wayvnc module (see main dotfiles README)
2. Run `configure-wayvnc` to set up authentication and sudoers rule
3. Reload Hyprland or login again

**For detailed information**, see [wayvnc/README.md](../wayvnc/README.md) which covers:
- Security model (PAM authentication, TLS encryption)
- SSH tunneling for secure remote access
- Configuration options
- Troubleshooting

**Quick test** (after wayvnc module setup):
```bash
# Check wayvnc is running
pgrep -a wayvnc

# Connect locally
vncviewer localhost:5900
```

## Scripts

### snap-window.sh

Snaps the active window to various screen positions, accounting for gaps.

**Usage:**
```bash
~/.config/hypr/scripts/snap-window.sh <position>
```

**Positions:** `left`, `right`, `top`, `bottom`, `topleft`, `topright`, `bottomleft`, `bottomright`, `center`

**How it works:**
1. Gets active monitor dimensions
2. Retrieves gap settings from Hyprland
3. Calculates target position accounting for gaps
4. Makes window floating (if tiled)
5. Moves and resizes window to target

### switch-layout.sh

Toggles between dwindle and master layouts with notification.

**Usage:**
```bash
~/.config/hypr/scripts/switch-layout.sh
```

**How it works:**
1. Reads current layout from Hyprland
2. Switches to opposite layout
3. Sends desktop notification (if notify-send available)

## Customization

### Change Gaps

Edit `general` section in `hyprland.conf`:
```conf
general {
    gaps_in = 5      # Gap between windows
    gaps_out = 20    # Gap from screen edges
}
```

### Change Border Colors

```conf
general {
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
}
```

Color format: `rgba(RRGGBBAA)` where AA is transparency (hex)

### Change Animation Speed

Edit `animations` section:
```conf
animation = windows, 1, 4.79, easeOutQuint
#                      ^  ^^^^
#                      |  duration (in deciseconds)
#                      enabled (1 or 0)
```

### Add Custom Keybindings

Add to keybindings section:
```conf
# Launch browser
bind = $mainMod, B, exec, firefox

# Move window with Super + Shift + Arrows
bind = $mainMod SHIFT, left, movewindow, l
```

See [Hyprland Binds Wiki](https://wiki.hypr.land/Configuring/Binds/)

## Machine-Specific Configuration

Stow uses `--no-folding`, allowing machine-specific files alongside stowed configs.

### Example: Local Monitor Configuration

Create `~/.config/hypr/local.conf`:
```conf
# Machine-specific monitor setup
monitor=DP-1,2560x1440@165,0x0,1
monitor=HDMI-A-1,1920x1080@60,2560x0,1

# Custom environment variables
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
```

Then source it in `hyprland.conf`:
```conf
# At the end of hyprland.conf
source = ~/.config/hypr/local.conf
```

This file won't be tracked in dotfiles and survives stow operations.

## Troubleshooting

### Hyprland Won't Start

1. Check logs:
   ```bash
   cat /tmp/hypr/$(ls -t /tmp/hypr/ | head -n 1)/hyprland.log
   ```

2. Validate config:
   ```bash
   hyprctl reload  # If in Hyprland session
   ```

### Scripts Not Executing

1. Verify executable permissions:
   ```bash
   ls -la ~/.config/hypr/scripts/
   # Should show -rwxr-xr-x
   ```

2. Fix if needed:
   ```bash
   chmod +x ~/.config/hypr/scripts/*.sh
   ```

3. Check dependencies:
   ```bash
   command -v hyprctl jq notify-send
   ```

### Keybindings Not Working

1. Check if key is already bound:
   ```bash
   hyprctl binds | grep -i <key>
   ```

2. Test binding manually:
   ```bash
   hyprctl dispatch exec kitty  # Should open terminal
   ```

3. Reload config:
   ```bash
   hyprctl reload
   ```

### High CPU/GPU Usage

1. Disable animations temporarily:
   ```conf
   animations {
       enabled = false
   }
   ```

2. Reduce blur:
   ```conf
   decoration {
       blur {
           enabled = false
       }
   }
   ```

3. Monitor performance:
   ```bash
   hyprctl monitors  # Check refresh rates
   hyprctl workspaces
   ```

### Screen Locks Too Quickly

Edit `hypridle.conf`:
```conf
listener {
    timeout = 900  # 15 minutes instead of 5
    on-timeout = loginctl lock-session
}
```

Then restart hypridle:
```bash
pkill hypridle && hypridle &
```

## Resources

- [Hyprland Wiki](https://wiki.hypr.land/)
- [Hyprland GitHub](https://github.com/hyprwm/Hyprland)
- [Awesome Hyprland](https://github.com/hyprland-community/awesome-hyprland) - Community resources
- [r/hyprland](https://reddit.com/r/hyprland) - Community discussion
