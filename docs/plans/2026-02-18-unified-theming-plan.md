# Unified Tokyo Night Theming Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Unify the Tokyo Night theme across the entire Hyprland desktop ecosystem — fix inconsistencies, fill gaps, build waybar, add GTK/QT/cursor theming, SDDM, swaync, and hyprpaper.

**Architecture:** GNU Stow modules, one per tool. New modules: `waybar/`, `theme/`, `sddm/`, `swaync/`. Existing `hyprland/` module gets border fix, env vars, hyprpaper config, and swaync autostart. All colors come from the Tokyo Night palette defined in the design doc.

**Tech Stack:** Hyprland, Waybar (jsonc + CSS), GTK3/2 settings, qt5ct, Kvantum, SDDM QML, swaync, hyprpaper, GNU Stow

---

## Tokyo Night Palette Quick Reference

Use these exact values everywhere:

| Name     | Hex       | Usage                    |
|----------|-----------|--------------------------|
| night    | `#1a1b26` | Darkest background       |
| storm    | `#24283b` | Panel/pill background    |
| bg_hover | `#292e42` | Hover states             |
| fg       | `#c0caf5` | Primary text             |
| fg_dim   | `#a9b1d6` | Dimmed text              |
| comment  | `#565f89` | Muted/inactive           |
| red      | `#f7768e` | Errors, urgent           |
| orange   | `#ff9e64` | Warnings                 |
| yellow   | `#e0af68` | Caution                  |
| green    | `#9ece6a` | Success, active          |
| teal     | `#73daca` | Info                     |
| blue     | `#7aa2f7` | Primary accent           |
| cyan     | `#7dcfff` | Links                    |
| magenta  | `#bb9af7` | Secondary accent         |

---

### Task 1: Hyprland Border Color Fix

Fix the off-palette border gradient in hyprland.conf to use Tokyo Night blue→magenta.

**Files:**
- Modify: `hyprland/.config/hypr/hyprland.conf:85-86`

**Step 1: Replace border colors**

In `hyprland/.config/hypr/hyprland.conf`, change lines 85-86 from:

```
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
```

to:

```
    col.active_border = rgba(7aa2f7ee) rgba(bb9af7ee) 45deg
    col.inactive_border = rgba(565f89aa)
```

**Step 2: Verify the file**

Run: `grep -n 'col\.' hyprland/.config/hypr/hyprland.conf`
Expected: Lines 85-86 show the new `7aa2f7` / `bb9af7` / `565f89` values.

**Step 3: Commit**

```bash
git add hyprland/.config/hypr/hyprland.conf
git commit -m "fix: unify hyprland borders to Tokyo Night palette

Replace off-palette #33ccff/#00ff99 gradient with Tokyo Night
blue (#7aa2f7) → magenta (#bb9af7) active border and
comment (#565f89) inactive border."
```

---

### Task 2: Hyprland Env Vars + Swaync Autostart

Add cursor/QT env vars and swaync to autostart.

**Files:**
- Modify: `hyprland/.config/hypr/hyprland.conf:39-51`

**Step 1: Add swaync to autostart**

In `hyprland/.config/hypr/hyprland.conf`, after line 41 (`exec-once = hypridle`), add:

```
exec-once = swaync
```

**Step 2: Update env vars**

Replace lines 50-51:

```
env = XCURSOR_SIZE,24
env = HYPRCURSOR_SIZE,24
```

with:

```
env = XCURSOR_SIZE,24
env = HYPRCURSOR_SIZE,24
env = XCURSOR_THEME,Bibata-Modern-Classic
env = QT_QPA_PLATFORMTHEME,qt5ct
```

**Step 3: Verify**

Run: `grep -n 'exec-once\|env =' hyprland/.config/hypr/hyprland.conf`
Expected: `swaync` in autostart, `XCURSOR_THEME` and `QT_QPA_PLATFORMTHEME` in env section.

**Step 4: Commit**

```bash
git add hyprland/.config/hypr/hyprland.conf
git commit -m "feat: add swaync autostart and cursor/QT env vars

Add swaync notification daemon to exec-once.
Set XCURSOR_THEME=Bibata-Modern-Classic and
QT_QPA_PLATFORMTHEME=qt5ct for unified theming."
```

---

### Task 3: Hypridle — Remove Auto-Lock Timeouts

Remove the 300s lock and 330s DPMS listener blocks. Keep the general block for sleep/wake.

**Files:**
- Modify: `hyprland/.config/hypr/hypridle.conf`

**Step 1: Remove listener blocks**

Replace the entire file content with just the general block:

```
general {
    lock_cmd = pidof hyprlock || hyprlock       # dbus/sysd lock command (loginctl lock-session)
    before_sleep_cmd = loginctl lock-session    # command to run before suspend
    after_sleep_cmd = hyprctl dispatch dpms on  # command to run when waking up
}
```

This removes:
- The 300s lock timeout listener (old lines 7-10)
- The 330s DPMS timeout listener (old lines 12-16)

**Step 2: Verify**

Run: `cat hyprland/.config/hypr/hypridle.conf`
Expected: Only the `general {}` block remains. No `listener` blocks.

**Step 3: Commit**

```bash
git add hyprland/.config/hypr/hypridle.conf
git commit -m "feat: remove hypridle auto-lock and DPMS timeouts

Lock screen now only triggers intentionally via keybind (Super+L).
Keep general block for sleep/wake handling."
```

---

### Task 4: Hyprpaper Configuration

Create the hyprpaper config pointing to the Tokyo Night wallpaper.

**Files:**
- Create: `hyprland/.config/hypr/hyprpaper.conf`

**Step 1: Create hyprpaper.conf**

Create `hyprland/.config/hypr/hyprpaper.conf`:

```
preload = ~/.local/share/dotfiles/wallpapers/tokyonight.jpg
wallpaper = ,~/.local/share/dotfiles/wallpapers/tokyonight.jpg
splash = false
```

**Step 2: Disable default Hyprland wallpaper**

In `hyprland/.config/hypr/hyprland.conf`, change line 192:

```
    force_default_wallpaper = -1 # Set to 0 or 1 to disable the anime mascot wallpapers
```

to:

```
    force_default_wallpaper = 0
```

And change line 193:

```
    disable_hyprland_logo = false # If true disables the random hyprland logo / anime girl background. :(
```

to:

```
    disable_hyprland_logo = true
```

**Step 3: Verify wallpaper file exists**

Run: `ls -la wallpapers/tokyonight.jpg`
Expected: File exists (already downloaded in design phase).

**Step 4: Commit**

```bash
git add hyprland/.config/hypr/hyprpaper.conf hyprland/.config/hypr/hyprland.conf
git commit -m "feat: configure hyprpaper with Tokyo Night wallpaper

Add hyprpaper.conf pointing to wallpapers/tokyonight.jpg.
Disable default Hyprland anime wallpaper/logo."
```

---

### Task 5: Waybar Module — Config

Create the waybar stow module with the floating pill config.

**Files:**
- Create: `waybar/.config/waybar/config.jsonc`
- Create: `waybar/deps.yaml`

**Step 1: Create deps.yaml**

Create `waybar/deps.yaml`:

```yaml
# waybar module dependencies
# Status bar + supporting tools for widgets
packages:
  arch:
    - waybar
    - wttrbar
    - playerctl
    - swaync
  debian:
    - waybar
    - playerctl
  fedora:
    - waybar
    - playerctl
  macos: []
```

**Step 2: Create config.jsonc**

Create `waybar/.config/waybar/config.jsonc`:

```jsonc
// Waybar Configuration — Tokyo Night Floating Pills
{
    "layer": "top",
    "position": "top",
    "margin-top": 8,
    "margin-left": 8,
    "margin-right": 8,
    "spacing": 4,

    // ── Module Layout ──────────────────────────────────────
    "modules-left": [
        "custom/arch",
        "clock",
        "custom/updates",
        "mpris",
        "custom/weather"
    ],
    "modules-center": [
        "hyprland/workspaces"
    ],
    "modules-right": [
        "wireplumber",
        "network",
        "battery",
        "custom/sysinfo",
        "custom/notification",
        "custom/power"
    ],

    // ── Left Modules ───────────────────────────────────────

    "custom/arch": {
        "format": " ",
        "tooltip": false
    },

    "clock": {
        "format": "  {:%H:%M}",
        "format-alt": "  {:%A, %B %d, %Y}",
        "tooltip-format": "<tt><small>{calendar}</small></tt>",
        "calendar": {
            "mode": "year",
            "mode-mon-col": 3,
            "weeks-pos": "right",
            "on-scroll": 1,
            "format": {
                "months": "<span color='#c0caf5'><b>{}</b></span>",
                "days": "<span color='#a9b1d6'>{}</span>",
                "weeks": "<span color='#565f89'>W{}</span>",
                "weekdays": "<span color='#7aa2f7'><b>{}</b></span>",
                "today": "<span color='#ff9e64'><b><u>{}</u></b></span>"
            }
        }
    },

    "custom/updates": {
        "format": "  {}",
        "interval": 3600,
        "exec": "checkupdates 2>/dev/null | wc -l",
        "exec-if": "which checkupdates",
        "on-click": "kitty -e sh -c 'yay -Syu; echo Done.; read'",
        "tooltip-format": "{}",
        "signal": 8
    },

    "mpris": {
        "format": "{player_icon}  {artist} — {title}",
        "format-paused": "{player_icon}  {status_icon} {artist} — {title}",
        "player-icons": {
            "default": "",
            "firefox": "",
            "spotify": ""
        },
        "status-icons": {
            "paused": ""
        },
        "max-length": 40,
        "ignored-players": ["firefox"]
    },

    "custom/weather": {
        "format": "{}",
        "interval": 900,
        "exec": "wttrbar --location auto --main-indicator temp_C --custom-indicator '{temp_C}°C {weatherDesc} 📍{areaName}' 2>/dev/null",
        "exec-if": "which wttrbar",
        "return-type": "json",
        "tooltip": true
    },

    // ── Center Modules ─────────────────────────────────────

    "hyprland/workspaces": {
        "format": "{id}",
        "on-click": "activate",
        "sort-by-number": true,
        "active-only": false,
        "all-outputs": true
    },

    // ── Right Modules ──────────────────────────────────────

    "wireplumber": {
        "format": "{icon}  {volume}%",
        "format-muted": "  muted",
        "format-icons": ["", "", ""],
        "on-click": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
        "on-scroll-up": "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+",
        "on-scroll-down": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-",
        "tooltip-format": "{node_name}: {volume}%"
    },

    "network": {
        "format-wifi": "  {essid}",
        "format-ethernet": "  {ifname}",
        "format-disconnected": "  offline",
        "tooltip-format-wifi": "  {essid}\n  {ipaddr}/{cidr}\n  {signalStrength}% signal\n  {bandwidthUpBits}↑ {bandwidthDownBits}↓",
        "tooltip-format-ethernet": "  {ifname}\n  {ipaddr}/{cidr}\n  {bandwidthUpBits}↑ {bandwidthDownBits}↓",
        "tooltip-format-disconnected": "No connection",
        "max-length": 20,
        "on-click": "kitty -e nmtui"
    },

    "battery": {
        "format": "{icon}  {capacity}%",
        "format-charging": "  {capacity}%",
        "format-plugged": "  {capacity}%",
        "format-icons": ["", "", "", "", ""],
        "states": {
            "warning": 20,
            "critical": 10
        },
        "tooltip-format": "{timeTo}\n{power}W draw"
    },

    "custom/sysinfo": {
        "format": " ",
        "on-click": "~/.config/waybar/scripts/sysinfo.sh",
        "tooltip": false
    },

    "custom/notification": {
        "exec": "swaync-client -swb",
        "return-type": "json",
        "format": "{icon}",
        "format-icons": {
            "notification": "<span foreground='#f7768e'>  </span>",
            "none": "  ",
            "dnd-notification": "<span foreground='#f7768e'>  </span>",
            "dnd-none": "  ",
            "inhibited-notification": "  ",
            "inhibited-none": "  ",
            "dnd-inhibited-notification": "  ",
            "dnd-inhibited-none": "  "
        },
        "on-click": "swaync-client -t -sw",
        "on-click-right": "swaync-client -d -sw",
        "escape": true,
        "tooltip": false
    },

    "custom/power": {
        "format": " ",
        "on-click": "~/.config/waybar/scripts/power-menu.sh",
        "tooltip": false
    }
}
```

**Step 3: Verify JSON is valid**

Run: `python3 -c "import json, re; f=open('waybar/.config/waybar/config.jsonc').read(); json.loads(re.sub(r'//.*', '', f))"`
Expected: No error (valid JSON after stripping comments).

**Step 4: Commit**

```bash
git add waybar/.config/waybar/config.jsonc waybar/deps.yaml
git commit -m "feat(waybar): add config with floating pill layout

Tokyo Night themed waybar with left (arch, clock, updates, media,
weather), center (workspaces), right (volume, network, battery,
sysinfo, notifications, power) pill modules."
```

---

### Task 6: Waybar Module — CSS Styling

Create the floating pill CSS with Tokyo Night palette.

**Files:**
- Create: `waybar/.config/waybar/style.css`

**Step 1: Create style.css**

Create `waybar/.config/waybar/style.css`:

```css
/* ═══════════════════════════════════════════════════════════
   Waybar — Tokyo Night Floating Pills
   Palette: night=#1a1b26 storm=#24283b bg_hover=#292e42
            fg=#c0caf5 fg_dim=#a9b1d6 comment=#565f89
            blue=#7aa2f7 magenta=#bb9af7 cyan=#7dcfff
            green=#9ece6a red=#f7768e orange=#ff9e64
            yellow=#e0af68 teal=#73daca
   ═══════════════════════════════════════════════════════════ */

/* ── Global ───────────────────────────────────────────── */

* {
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 12px;
    min-height: 0;
}

window#waybar {
    background: transparent;
    color: #c0caf5;
}

tooltip {
    background: #1a1b26;
    border: 1px solid #7aa2f7;
    border-radius: 10px;
    color: #c0caf5;
}

tooltip label {
    color: #c0caf5;
    padding: 4px 8px;
}

/* ── Pill Base ────────────────────────────────────────── */

#custom-arch,
#clock,
#custom-updates,
#mpris,
#custom-weather,
#workspaces,
#wireplumber,
#network,
#battery,
#custom-sysinfo,
#custom-notification,
#custom-power {
    background: rgba(36, 40, 59, 0.85);
    border-radius: 20px;
    padding: 4px 14px;
    margin: 2px 3px;
    transition: all 0.3s ease;
}

#custom-arch:hover,
#clock:hover,
#custom-updates:hover,
#mpris:hover,
#custom-weather:hover,
#wireplumber:hover,
#network:hover,
#battery:hover,
#custom-sysinfo:hover,
#custom-notification:hover,
#custom-power:hover {
    background: rgba(41, 46, 66, 0.95);
}

/* ── Left Modules ─────────────────────────────────────── */

#custom-arch {
    color: #7aa2f7;
    font-size: 16px;
    padding: 4px 12px;
}

#clock {
    color: #c0caf5;
}

#custom-updates {
    color: #9ece6a;
}

#mpris {
    color: #bb9af7;
    max-width: 250px;
}

#custom-weather {
    color: #7dcfff;
}

/* ── Center — Workspaces ──────────────────────────────── */

#workspaces {
    padding: 2px 6px;
}

#workspaces button {
    color: #565f89;
    background: transparent;
    border-radius: 14px;
    padding: 2px 10px;
    margin: 0 2px;
    transition: all 0.3s ease;
    border: none;
}

#workspaces button:hover {
    color: #c0caf5;
    background: rgba(41, 46, 66, 0.6);
}

#workspaces button.active {
    color: #1a1b26;
    background: #7aa2f7;
    font-weight: bold;
}

#workspaces button.urgent {
    color: #1a1b26;
    background: #f7768e;
}

/* ── Right Modules ────────────────────────────────────── */

#wireplumber {
    color: #e0af68;
}

#wireplumber.muted {
    color: #565f89;
}

#network {
    color: #73daca;
}

#network.disconnected {
    color: #565f89;
}

#battery {
    color: #9ece6a;
}

#battery.charging {
    color: #73daca;
}

#battery.warning:not(.charging) {
    color: #ff9e64;
}

#battery.critical:not(.charging) {
    color: #f7768e;
    animation: blink 1s ease infinite alternate;
}

@keyframes blink {
    to {
        color: #1a1b26;
        background: #f7768e;
    }
}

#custom-sysinfo {
    color: #7dcfff;
}

#custom-notification {
    color: #c0caf5;
}

#custom-power {
    color: #f7768e;
}

#custom-power:hover {
    background: rgba(247, 118, 142, 0.2);
}
```

**Step 2: Commit**

```bash
git add waybar/.config/waybar/style.css
git commit -m "feat(waybar): add Tokyo Night floating pill CSS

Transparent bar background, individual rounded pill modules at
85% opacity storm background, hover transitions, workspace active
states with blue highlight, battery status animations."
```

---

### Task 7: Waybar Module — Scripts

Create the sysinfo and power menu scripts.

**Files:**
- Create: `waybar/.config/waybar/scripts/sysinfo.sh`
- Create: `waybar/.config/waybar/scripts/power-menu.sh`

**Step 1: Create sysinfo.sh**

Create `waybar/.config/waybar/scripts/sysinfo.sh`:

```bash
#!/usr/bin/env bash
# System info popup for waybar — shows CPU, MEM, DISK, GPU usage
# Displayed via notify-send for simplicity (swaync will style it)

cpu=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%.0f", $2}')
mem=$(free -m | awk '/Mem:/ {printf "%.0f", $3/$2*100}')
mem_used=$(free -h | awk '/Mem:/ {print $3}')
mem_total=$(free -h | awk '/Mem:/ {print $2}')
disk=$(df -h / | awk 'NR==2 {printf "%s/%s (%s)", $3, $2, $5}')

# GPU info (nvidia-smi if available, otherwise skip)
if command -v nvidia-smi &>/dev/null; then
    gpu_util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)
    gpu_mem=$(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null | head -1)
    gpu_mem_used=$(echo "$gpu_mem" | cut -d',' -f1 | xargs)
    gpu_mem_total=$(echo "$gpu_mem" | cut -d',' -f2 | xargs)
    gpu_line="\n  GPU Compute: ${gpu_util}%\n  GPU VRAM: ${gpu_mem_used}/${gpu_mem_total} MiB"
else
    gpu_line=""
fi

notify-send -a "System Monitor" "System Resources" \
    "  CPU: ${cpu}%\n  Memory: ${mem_used}/${mem_total} (${mem}%)\n  Disk (/): ${disk}${gpu_line}" \
    -t 10000
```

**Step 2: Create power-menu.sh**

Create `waybar/.config/waybar/scripts/power-menu.sh`:

```bash
#!/usr/bin/env bash
# Power menu via rofi — matches Tokyo Night theme via existing rofi config

chosen=$(printf "  Lock\n  Logout\n  Reboot\n  Shutdown" | rofi -dmenu -p "Power" -i -theme-str 'window {width: 200px;}')

case "$chosen" in
    *Lock)     hyprlock ;;
    *Logout)   hyprctl dispatch exit ;;
    *Reboot)   systemctl reboot ;;
    *Shutdown) systemctl poweroff ;;
esac
```

**Step 3: Make scripts executable**

Run: `chmod +x waybar/.config/waybar/scripts/sysinfo.sh waybar/.config/waybar/scripts/power-menu.sh`

**Step 4: Commit**

```bash
git add waybar/.config/waybar/scripts/
git commit -m "feat(waybar): add sysinfo popup and power menu scripts

sysinfo.sh: CPU/MEM/DISK/GPU stats via notify-send.
power-menu.sh: lock/logout/reboot/shutdown via rofi."
```

---

### Task 8: Swaync Module

Create the swaync notification daemon stow module with Tokyo Night theme.

**Files:**
- Create: `swaync/.config/swaync/config.json`
- Create: `swaync/.config/swaync/style.css`
- Create: `swaync/deps.yaml`

**Step 1: Create deps.yaml**

Create `swaync/deps.yaml`:

```yaml
# swaync module dependencies
# Notification daemon for Wayland
packages:
  arch:
    - swaync
  debian:
    - sway-notification-center
  fedora:
    - SwayNotificationCenter
  macos: []
```

**Step 2: Create config.json**

Create `swaync/.config/swaync/config.json`:

```json
{
    "$schema": "/etc/xdg/swaync/configSchema.json",
    "positionX": "right",
    "positionY": "top",
    "control-center-margin-top": 10,
    "control-center-margin-bottom": 10,
    "control-center-margin-right": 10,
    "control-center-width": 380,
    "notification-window-width": 380,
    "notification-icon-size": 48,
    "notification-body-image-height": 100,
    "notification-body-image-width": 200,
    "timeout": 6,
    "timeout-low": 4,
    "timeout-critical": 0,
    "fit-to-screen": true,
    "keyboard-shortcuts": true,
    "image-visibility": "when-available",
    "transition-time": 200,
    "hide-on-clear": false,
    "hide-on-action": true,
    "script-fail-notify": true,
    "widgets": [
        "title",
        "notifications",
        "mpris",
        "volume",
        "buttons-grid"
    ],
    "widget-config": {
        "title": {
            "text": "Notifications",
            "clear-all-button": true,
            "button-text": " Clear"
        },
        "mpris": {
            "image-size": 64,
            "image-radius": 8
        },
        "volume": {
            "label": " "
        },
        "buttons-grid": {
            "actions": [
                {
                    "label": " ",
                    "command": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
                },
                {
                    "label": " ",
                    "command": "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
                },
                {
                    "label": "  ",
                    "command": "swaync-client -d"
                }
            ]
        }
    }
}
```

**Step 3: Create style.css**

Create `swaync/.config/swaync/style.css`:

```css
/* ═══════════════════════════════════════════════════════════
   Swaync — Tokyo Night Theme
   ═══════════════════════════════════════════════════════════ */

* {
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 13px;
}

/* ── Notification Window ──────────────────────────────── */

.notification-row {
    outline: none;
}

.notification {
    background: #24283b;
    border: 1px solid #7aa2f7;
    border-radius: 10px;
    margin: 6px;
    padding: 0;
    transition: all 0.3s ease;
}

.notification:hover {
    border-color: #bb9af7;
}

.notification-content {
    padding: 8px 12px;
}

.summary {
    color: #c0caf5;
    font-weight: bold;
    font-size: 14px;
}

.body {
    color: #a9b1d6;
}

.time {
    color: #565f89;
    font-size: 11px;
}

.notification.critical {
    border-color: #f7768e;
}

.notification.low {
    border-color: #565f89;
}

.close-button {
    background: #292e42;
    color: #c0caf5;
    border-radius: 50%;
    padding: 2px;
    margin: 4px;
    border: none;
    transition: all 0.2s ease;
}

.close-button:hover {
    background: #f7768e;
    color: #1a1b26;
}

/* ── Control Center ───────────────────────────────────── */

.control-center {
    background: rgba(26, 27, 38, 0.95);
    border: 1px solid #7aa2f7;
    border-radius: 10px;
    padding: 10px;
}

.control-center .notification {
    background: #24283b;
}

/* ── Title Widget ─────────────────────────────────────── */

.widget-title {
    color: #c0caf5;
    font-size: 15px;
    font-weight: bold;
    margin: 8px;
}

.widget-title > button {
    background: #24283b;
    color: #f7768e;
    border: 1px solid #565f89;
    border-radius: 8px;
    padding: 4px 12px;
    transition: all 0.2s ease;
}

.widget-title > button:hover {
    background: rgba(247, 118, 142, 0.2);
    border-color: #f7768e;
}

/* ── Buttons Grid ─────────────────────────────────────── */

.widget-buttons-grid {
    padding: 4px 8px;
}

.widget-buttons-grid > flowbox > flowboxchild > button {
    background: #24283b;
    color: #c0caf5;
    border: 1px solid #565f89;
    border-radius: 10px;
    padding: 8px 12px;
    margin: 4px;
    transition: all 0.2s ease;
}

.widget-buttons-grid > flowbox > flowboxchild > button:hover {
    background: #292e42;
    border-color: #7aa2f7;
}

.widget-buttons-grid > flowbox > flowboxchild > button.toggle:checked {
    background: rgba(122, 162, 247, 0.2);
    border-color: #7aa2f7;
    color: #7aa2f7;
}

/* ── MPRIS Widget ─────────────────────────────────────── */

.widget-mpris {
    background: #24283b;
    border-radius: 10px;
    padding: 8px;
    margin: 4px 8px;
}

.widget-mpris-title {
    color: #c0caf5;
    font-weight: bold;
}

.widget-mpris-subtitle {
    color: #a9b1d6;
}

/* ── Volume Widget ────────────────────────────────────── */

.widget-volume {
    background: #24283b;
    border-radius: 10px;
    padding: 8px;
    margin: 4px 8px;
}

.widget-volume trough {
    background: #1a1b26;
    border-radius: 4px;
}

.widget-volume highlight {
    background: #7aa2f7;
    border-radius: 4px;
}
```

**Step 4: Commit**

```bash
git add swaync/
git commit -m "feat(swaync): add notification daemon with Tokyo Night theme

Config with control center widgets (title, notifications, mpris,
volume, buttons-grid). CSS uses Tokyo Night palette with rounded
corners, blue accent borders, smooth transitions."
```

---

### Task 9: Theme Module — GTK / QT / Cursor

Create the `theme/` stow module for desktop appearance.

**Files:**
- Create: `theme/.config/gtk-3.0/settings.ini`
- Create: `theme/.gtkrc-2.0`
- Create: `theme/.config/qt5ct/qt5ct.conf`
- Create: `theme/.config/Kvantum/kvantum.kvconfig`
- Create: `theme/.icons/default/index.theme`
- Create: `theme/deps.yaml`

**Step 1: Create deps.yaml**

Create `theme/deps.yaml`:

```yaml
# theme module dependencies
# GTK, QT, and cursor theme packages
packages:
  arch:
    - kvantum
    - qt5ct
    - tokyonight-gtk-theme-git   # AUR
    - papirus-icon-theme
    - bibata-cursor-theme         # AUR
  debian:
    - qt5ct
    - papirus-icon-theme
  fedora:
    - kvantum
    - qt5ct
    - papirus-icon-theme
  macos: []
```

**Step 2: Create GTK3 settings**

Create `theme/.config/gtk-3.0/settings.ini`:

```ini
[Settings]
gtk-theme-name=Tokyonight-Dark-BL
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=JetBrainsMono Nerd Font 10
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
gtk-application-prefer-dark-theme=1
```

**Step 3: Create GTK2 settings**

Create `theme/.gtkrc-2.0`:

```
gtk-theme-name="Tokyonight-Dark-BL"
gtk-icon-theme-name="Papirus-Dark"
gtk-font-name="JetBrainsMono Nerd Font 10"
gtk-cursor-theme-name="Bibata-Modern-Classic"
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintslight"
gtk-xft-rgba="rgb"
```

**Step 4: Create qt5ct config**

Create `theme/.config/qt5ct/qt5ct.conf`:

```ini
[Appearance]
color_scheme_path=
custom_palette=false
icon_theme=Papirus-Dark
standard_dialogs=default
style=kvantum

[Fonts]
fixed="JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0,Regular"
general="JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0,Regular"

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3
```

**Step 5: Create Kvantum config**

Create `theme/.config/Kvantum/kvantum.kvconfig`:

```ini
[General]
theme=KvTokyoNight
```

**Step 6: Create cursor index.theme**

Create `theme/.icons/default/index.theme`:

```ini
[Icon Theme]
Name=Default
Comment=Default cursor theme
Inherits=Bibata-Modern-Classic
```

**Step 7: Commit**

```bash
git add theme/
git commit -m "feat(theme): add GTK/QT/cursor theming module

GTK: Tokyonight-Dark-BL theme, Papirus-Dark icons
QT: Kvantum with Tokyo Night, qt5ct config
Cursor: Bibata-Modern-Classic at size 24
Font: JetBrainsMono Nerd Font throughout"
```

---

### Task 10: SDDM Custom Theme

Create a minimal Tokyo Night SDDM login theme.

**Files:**
- Create: `sddm/theme/tokyonight-minimal/metadata.desktop`
- Create: `sddm/theme/tokyonight-minimal/theme.conf`
- Create: `sddm/theme/tokyonight-minimal/Main.qml`
- Create: `sddm/scripts/install-sddm-theme.sh`
- Create: `sddm/deps.yaml`

**Step 1: Create deps.yaml**

Create `sddm/deps.yaml`:

```yaml
# sddm module dependencies
# Display manager with custom theme
packages:
  arch:
    - sddm
    - qt6-5compat
    - qt6-svg
  debian:
    - sddm
  fedora:
    - sddm
  macos: []
```

**Step 2: Create metadata.desktop**

Create `sddm/theme/tokyonight-minimal/metadata.desktop`:

```ini
[SddmGreeterTheme]
Name=Tokyo Night Minimal
Description=Minimal Tokyo Night themed SDDM login screen
Author=dotfiles
Version=1.0
Website=
Screenshot=
MainScript=Main.qml
ConfigFile=theme.conf
TranslationsDirectory=translations
```

**Step 3: Create theme.conf**

Create `sddm/theme/tokyonight-minimal/theme.conf`:

```ini
[General]
Background=#1a1b26
Font=JetBrainsMono Nerd Font
FontSize=12
```

**Step 4: Create Main.qml**

Create `sddm/theme/tokyonight-minimal/Main.qml`:

```qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: "#1a1b26"

    property string fontFamily: "JetBrainsMono Nerd Font"

    // ── Clock ───────────────────────────────────────────
    Text {
        id: clock
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.15
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: root.fontFamily
        font.pixelSize: 72
        font.weight: Font.Light
        color: "#c0caf5"
        text: Qt.formatTime(new Date(), "HH:mm")

        Timer {
            interval: 30000
            running: true
            repeat: true
            onTriggered: clock.text = Qt.formatTime(new Date(), "HH:mm")
        }
    }

    Text {
        id: dateText
        anchors.top: clock.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: root.fontFamily
        font.pixelSize: 16
        color: "#565f89"
        text: Qt.formatDate(new Date(), "dddd, MMMM d")

        Timer {
            interval: 60000
            running: true
            repeat: true
            onTriggered: dateText.text = Qt.formatDate(new Date(), "dddd, MMMM d")
        }
    }

    // ── Login Form ──────────────────────────────────────
    Column {
        id: loginForm
        anchors.centerIn: parent
        spacing: 16
        width: 320

        // Username field
        TextField {
            id: userField
            width: parent.width
            height: 44
            placeholderText: "Username"
            text: userModel.lastUser
            font.family: root.fontFamily
            font.pixelSize: 14
            color: "#c0caf5"
            horizontalAlignment: TextInput.AlignHCenter

            background: Rectangle {
                color: "#24283b"
                radius: 22
                border.color: userField.activeFocus ? "#7aa2f7" : "#565f89"
                border.width: 2

                Behavior on border.color {
                    ColorAnimation { duration: 200 }
                }
            }

            Keys.onTabPressed: passwordField.forceActiveFocus()
            Keys.onReturnPressed: sddm.login(userField.text, passwordField.text, sessionModel.lastIndex)
        }

        // Password field
        TextField {
            id: passwordField
            width: parent.width
            height: 44
            placeholderText: "Password"
            echoMode: TextInput.Password
            font.family: root.fontFamily
            font.pixelSize: 14
            color: "#c0caf5"
            horizontalAlignment: TextInput.AlignHCenter

            background: Rectangle {
                color: "#24283b"
                radius: 22
                border.color: passwordField.activeFocus ? "#7aa2f7" : "#565f89"
                border.width: 2

                Behavior on border.color {
                    ColorAnimation { duration: 200 }
                }
            }

            Keys.onReturnPressed: sddm.login(userField.text, passwordField.text, sessionModel.lastIndex)
        }

        // Error message
        Text {
            id: errorMsg
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.family: root.fontFamily
            font.pixelSize: 12
            color: "#f7768e"
            text: ""
            visible: text !== ""
        }
    }

    // ── Power Buttons ───────────────────────────────────
    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 16

        // Reboot pill
        Rectangle {
            width: 100
            height: 36
            radius: 18
            color: rebootMouse.containsMouse ? "#292e42" : "#24283b"
            border.color: rebootMouse.containsMouse ? "#7aa2f7" : "#565f89"
            border.width: 1

            Behavior on color { ColorAnimation { duration: 200 } }
            Behavior on border.color { ColorAnimation { duration: 200 } }

            Text {
                anchors.centerIn: parent
                text: "  Reboot"
                font.family: root.fontFamily
                font.pixelSize: 13
                color: "#c0caf5"
            }

            MouseArea {
                id: rebootMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: sddm.reboot()
                cursorShape: Qt.PointingHandCursor
            }
        }

        // Shutdown pill
        Rectangle {
            width: 110
            height: 36
            radius: 18
            color: shutdownMouse.containsMouse ? "#292e42" : "#24283b"
            border.color: shutdownMouse.containsMouse ? "#f7768e" : "#565f89"
            border.width: 1

            Behavior on color { ColorAnimation { duration: 200 } }
            Behavior on border.color { ColorAnimation { duration: 200 } }

            Text {
                anchors.centerIn: parent
                text: "  Shutdown"
                font.family: root.fontFamily
                font.pixelSize: 13
                color: "#c0caf5"
            }

            MouseArea {
                id: shutdownMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: sddm.powerOff()
                cursorShape: Qt.PointingHandCursor
            }
        }
    }

    // ── SDDM Connections ────────────────────────────────
    Connections {
        target: sddm
        function onLoginFailed() {
            passwordField.text = ""
            errorMsg.text = "Login failed"
            passwordField.forceActiveFocus()
        }
        function onLoginSucceeded() {
            errorMsg.text = ""
        }
    }

    Component.onCompleted: {
        if (userField.text !== "") {
            passwordField.forceActiveFocus()
        } else {
            userField.forceActiveFocus()
        }
    }
}
```

**Step 5: Create install script**

Create `sddm/scripts/install-sddm-theme.sh`:

```bash
#!/usr/bin/env bash
# Install the Tokyo Night Minimal SDDM theme
# Must be run with sudo

set -euo pipefail

THEME_NAME="tokyonight-minimal"
THEME_SRC="$(dirname "$(dirname "$(readlink -f "$0")")")/theme/${THEME_NAME}"
THEME_DEST="/usr/share/sddm/themes/${THEME_NAME}"

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (sudo)."
    exit 1
fi

echo "Installing SDDM theme: ${THEME_NAME}"
echo "  From: ${THEME_SRC}"
echo "  To:   ${THEME_DEST}"

# Copy theme files
rm -rf "${THEME_DEST}"
cp -r "${THEME_SRC}" "${THEME_DEST}"

# Configure SDDM to use the theme
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/theme.conf << EOF
[Theme]
Current=${THEME_NAME}

[General]
InputMethod=
EOF

echo "Done. SDDM will use ${THEME_NAME} on next login."
```

**Step 6: Make install script executable**

Run: `chmod +x sddm/scripts/install-sddm-theme.sh`

**Step 7: Commit**

```bash
git add sddm/
git commit -m "feat(sddm): add minimal Tokyo Night login theme

Custom QML theme with: clock, username/password fields with
rounded pill styling, reboot/shutdown pill buttons. Night
background, blue accent on focus, smooth hover transitions.
Includes install script for /usr/share/sddm/themes/."
```

---

### Task 11: Update config.yaml

Add all new modules to config.yaml.

**Files:**
- Modify: `config.yaml`

**Step 1: Add new modules**

After the `hyprland` entry (line 117) in `config.yaml`, add the following new modules:

```yaml
  - name: "waybar"
    path: "waybar"
    hosts:
      - HOME-DESKTOP
      - ASUS-LAPTOP
  - name: "theme"
    path: "theme"
    hosts:
      - HOME-DESKTOP
      - ASUS-LAPTOP
  - name: "sddm"
    path: "sddm"
    hosts:
      - HOME-DESKTOP
      - ASUS-LAPTOP
  - name: "swaync"
    path: "swaync"
    hosts:
      - HOME-DESKTOP
      - ASUS-LAPTOP
```

These follow the same pattern as hyprland (Hyprland-only hosts: HOME-DESKTOP, ASUS-LAPTOP).

**Step 2: Verify**

Run: `grep -A2 'name:.*waybar\|name:.*theme\|name:.*sddm\|name:.*swaync' config.yaml`
Expected: All four new modules listed with correct hosts.

**Step 3: Commit**

```bash
git add config.yaml
git commit -m "feat: register waybar, theme, sddm, swaync modules in config.yaml

New stow modules for Hyprland desktop hosts (HOME-DESKTOP,
ASUS-LAPTOP). Enables unified theming deployment via install.sh."
```

---

### Task 12: Deploy and Verify

Run stow to deploy all new symlinks and verify.

**Step 1: Run the installer**

Run: `./install.sh`
Expected: No stow errors. All new symlinks created.

**Step 2: Verify symlinks exist**

Run:
```bash
ls -la ~/.config/waybar/config.jsonc
ls -la ~/.config/waybar/style.css
ls -la ~/.config/swaync/config.json
ls -la ~/.config/gtk-3.0/settings.ini
ls -la ~/.config/hypr/hyprpaper.conf
```
Expected: All point back to the dotfiles repo.

**Step 3: Final commit (if any stow fixes needed)**

Only if adjustments were needed during deployment.

---

## Execution Order Summary

| Task | Component              | Type    |
|------|------------------------|---------|
| 1    | Hyprland border fix    | Modify  |
| 2    | Hyprland env + swaync  | Modify  |
| 3    | Hypridle timeouts      | Modify  |
| 4    | Hyprpaper config       | Create  |
| 5    | Waybar config          | Create  |
| 6    | Waybar CSS             | Create  |
| 7    | Waybar scripts         | Create  |
| 8    | Swaync module          | Create  |
| 9    | Theme module           | Create  |
| 10   | SDDM theme            | Create  |
| 11   | config.yaml update     | Modify  |
| 12   | Deploy + verify        | Test    |
