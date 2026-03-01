# Material Design 3 Theme for Rofi & Waybar

## Overview

Modern Material Design 3 theme with deep purple primary color and AMOLED black backgrounds.

## Features

- **Pure AMOLED Black**: True #000000 backgrounds for OLED displays
- **Material Design 3**: Authentic MD3 color system and motion
- **Deep Purple**: Primary color #D0BCFF with proper tonal palette
- **Smooth Animations**: Material Motion emphasized easing curves
- **Card-Based UI**: Rofi uses 2-column card grid
- **Filled Containers**: Waybar modules use filled surface containers

## Color Palette

### Primary
- Primary: `#D0BCFF`
- Primary Container: `#4F378B`
- On Primary Container: `#EADDFF`

### Surface
- Background: `#000000` (pure black)
- Surface Container: `#1E1E21`
- Surface Container High: `#282829`
- Surface Container Highest: `#33333D`

### Text
- On Surface: `#E6E1E5`
- On Surface Variant: `#CAC4D0`

## Reverting to Tokyo Night

Backup files are preserved:

```bash
# Restore rofi
cp rofi/.config/rofi/config-tokyonight-backup.rasi rofi/.config/rofi/config.rasi

# Restore waybar
cp waybar/.config/waybar/style-tokyonight-backup.css waybar/.config/waybar/style.css
cp waybar/.config/waybar/config-tokyonight-backup.jsonc waybar/.config/waybar/config.jsonc

# Restart waybar
pkill waybar && waybar &
```

## Customization

### Changing Primary Color

Edit color variables in:
- `rofi/.config/rofi/config.rasi` (lines 15-20)
- `waybar/.config/waybar/style.css` (lines 9-14)

### Adjusting Module Spacing

Edit waybar module padding/margin in `style.css`:
```css
padding: 8px 16px;  /* Vertical Horizontal */
margin: 2px 4px;    /* Vertical Horizontal */
```

### Adjusting Rofi Grid

Edit in `config.rasi`:
```rasi
listview {
    columns: 2;  /* Change to 3 for more columns */
    lines: 4;    /* Change for more rows */
}
```

## Dependencies

Required:
- rofi
- waybar
- JetBrainsMono Nerd Font
- Papirus-Dark icon theme

Optional:
- Hyprland (for blur effects)
- swaync (for notifications)
