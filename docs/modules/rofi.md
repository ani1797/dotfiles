---
layout: default
title: "Rofi Launcher"
parent: Modules
---

# Rofi Configuration

Tokyo Night themed application launcher for Wayland/X11.

## Features

- **Tokyo Night Storm Theme**: Dark blue background with vibrant accent colors
- **4x4 Grid Layout**: Display 16 applications at once with large 48px icons
- **Glass Hover Effect**: Subtle transparency and blue borders on selection
- **Search-First Design**: Clean search bar with prominent prompt
- **Multi-Mode Support**: drun (apps), run (commands), window (switcher)
- **Papirus Icon Theme**: Beautiful, consistent icon set

## Files

```
.config/rofi/
└── config.rasi         # Main configuration file
```

## Dependencies

- `rofi` - Application launcher
- `papirus-icon-theme` - Icon set
- `JetBrainsMono Nerd Font` - Monospace font with icons

Install dependencies:
```bash
# Arch Linux
sudo pacman -S rofi papirus-icon-theme ttf-jetbrains-mono-nerd

# Debian/Ubuntu
sudo apt install rofi papirus-icon-theme fonts-jetbrains-mono
```

## Usage

Launch rofi modes:
```bash
rofi -show drun      # Application launcher (default)
rofi -show run       # Command runner
rofi -show window    # Window switcher
```

### Keybindings

When rofi is open:
- `Enter` - Launch selected application
- `Escape` - Close without launching
- `Arrow keys` / `hjkl` - Navigate grid
- `Tab` - Switch between modes
- Type to search applications

### Hyprland Integration

Configured in `~/.config/hypr/hyprland.conf`:
```
bind = $mainMod, R, exec, rofi -show drun
bind = $mainMod, SUPER_L, exec, rofi -show drun
```

## Customization

### Change Grid Size

Edit `.config/rofi/config.rasi`:
```rasi
listview {
    columns: 4;  # Number of columns
    lines: 4;    # Number of rows
}
```

### Change Window Size

```rasi
window {
    width: 800px;    # Total width
    padding: 20px;   # Internal padding
}
```

### Change Icon Size

```rasi
element-icon {
    size: 48px;  # Icon dimensions
}
```

### Change Colors

All Tokyo Night colors are defined at the top of `config.rasi`:
```rasi
* {
    bg-col: #24283b;           // Background
    border-col: #7aa2f7;       // Blue borders
    blue: #7aa2f7;             // Accent color
    fg-col: #c0caf5;           // Text color
    // ... more colors
}
```

### Use Different Icon Theme

Edit the `configuration` block:
```rasi
configuration {
    icon-theme: "Papirus-Dark";  # Change this
}
```

Common alternatives: `Adwaita`, `breeze`, `Numix`, `Moka`

## Machine-Specific Overrides

Since stow uses `--no-folding`, you can create machine-specific files:

```bash
# Create local override
cat > ~/.config/rofi/local.rasi << 'EOF'
@import "config.rasi"

/* Override specific values */
* {
    font: "Ubuntu 11";
}
EOF
```

Then launch with: `rofi -show drun -config ~/.config/rofi/local.rasi`

## Troubleshooting

### Icons Not Showing

1. Verify icon theme installed:
   ```bash
   ls /usr/share/icons/ | grep -i papirus
   ```

2. Check rofi can find icons:
   ```bash
   rofi -show drun -show-icons
   ```

3. Try different icon theme in config.rasi

### Wrong Terminal Opens

Rofi uses the terminal specified in config.rasi:
```rasi
configuration {
    terminal: "alacritty";  # Change to your terminal
}
```

### Theme Not Applied

1. Ensure config.rasi is in `~/.config/rofi/`
2. Check for syntax errors:
   ```bash
   rofi -show drun -config ~/.config/rofi/config.rasi
   ```

### Blurry or Low-Resolution Icons

Increase icon size in config.rasi:
```rasi
element-icon {
    size: 64px;  # Increase from 48px
}
```

## Resources

- [Rofi Documentation](https://github.com/davatorium/rofi)
- [Rofi Themes](https://github.com/davatorium/rofi-themes)
- [Tokyo Night Color Scheme](https://github.com/enkia/tokyo-night-vscode-theme)
