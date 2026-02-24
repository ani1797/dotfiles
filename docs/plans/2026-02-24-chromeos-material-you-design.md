# ChromeOS-Inspired Material You Desktop Shell

**Date:** 2026-02-24
**Status:** Design Approved
**Goal:** Complete system redesign with AGS, Material You dynamic colors, ChromeOS aesthetics

---

## Overview

Transform the dotfiles setup from Tokyo Night cyberpunk theme to a ChromeOS-inspired Material You design system. This involves replacing waybar, swaync, and rofi with AGS (Aylur's GTK Shell), implementing dynamic color generation from wallpapers, and creating cohesive lock screen and login themes.

**Key Design Principles:**
- **Material You:** Dynamic color generation from wallpaper using Material Design 3
- **ChromeOS Layout:** Top shelf with launcher, full-screen app grid, dropdown quick settings
- **Minimal Tools:** Consolidate UI components into AGS (one tool replacing three)
- **System-wide Cohesion:** All components (terminal, editor, compositor) use generated colors
- **Dark Mode First:** Dark mode as primary with auto-rotation wallpaper support

---

## Architecture Overview

### Technology Stack

**Core Components:**
- **AGS (Aylur's GTK Shell)** - TypeScript/JavaScript desktop shell toolkit
- **Material Color Utilities** - Official Material You color generation library
- **Hyprpaper** - Wallpaper manager (already installed)
- **Hyprlock** - Lock screen with Material You styling
- **SDDM** - Login screen with custom Material You QML theme

**What Gets Replaced:**
- ❌ Waybar → AGS shelf widget
- ❌ Swaync → AGS notification system
- ❌ Rofi (mostly) → AGS app launcher & quick settings
- ✅ Keep: Hyprland, Kitty, Neovim, Starship (restyle with dynamic colors)

### Module Structure

```
ags/                               # New module
├── config.js                      # Main entry point
├── package.json                   # NPM dependencies
├── widgets/                       # UI components
│   ├── shelf/                     # Top bar
│   ├── applauncher/               # Full-screen app grid
│   ├── quicksettings/             # Control center dropdown
│   └── notifications/             # Notification panel
├── services/                      # Core services
│   ├── wallpaper.ts               # Auto-rotation + color extraction
│   ├── colorExtractor.ts          # Material You palette generator
│   ├── theme.ts                   # Dark/light mode manager
│   ├── network.ts                 # Network management
│   ├── audio.ts                   # Audio controls
│   ├── bluetooth.ts               # Bluetooth management
│   └── powerProfiles.ts           # Power profile switching
├── styles/                        # SCSS stylesheets
│   ├── main.scss                  # Main stylesheet
│   ├── _material-colors.scss      # Generated colors
│   └── exports/                   # Color exports for other apps
│       ├── material-colors.css    # CSS variables
│       ├── material-colors.conf   # Key=value format
│       ├── material-colors.json   # JSON structure
│       └── material-colors.sh     # Shell variables
└── scripts/
    ├── sync-colors.sh             # Propagate colors system-wide
    └── wallpaper-rotate.sh        # Rotation timer

hyprlock/                          # Lock screen redesign
├── hyprlock.conf                  # Material You config
└── scripts/update-colors.sh       # Apply current palette

sddm/                              # Login screen theme
└── themes/material-you/
    ├── Main.qml                   # Root component
    ├── components/                # UI components
    └── theme.conf                 # Theme metadata
```

---

## UI Components & Layout

### Top Shelf (Primary Bar)

**Visual Layout:**
```
┌─────────────────────────────────────────────────────────────────┐
│ [⊞] Chrome  Firefox  Terminal  Code  │  [≡] 14:30  [] [] []   │
│  ^      ^pinned apps with icons^     │   ^workspace  ^systray  │
│launcher                               │   switcher   (wifi,vol,│
│                                       │              power,etc) │
└─────────────────────────────────────────────────────────────────┘
```

**Specifications:**
- **Position:** Top of screen (not bottom like ChromeOS)
- **Height:** 48px
- **Background:** Surface color with 2dp elevation, 90% opacity + blur
- **Launcher icon:** Material You colored circle with grid icon
- **App icons:** 32px, shows dot indicator for running apps
- **Workspace indicator:** Shows current workspace number (1-9)
- **System tray:** Minimal icons (WiFi, volume, battery, notifications, clock)

### Full-Screen App Launcher

**Triggered:** Click launcher icon on shelf

**Layout:**
- Full screen overlay with translucent background
- Search bar at top (real-time filtering)
- 6-column grid of app icons (96px each)
- Recent apps section at bottom (last 5 with context)
- Material You primary container background
- Fade + scale animation from launcher button

**Interaction:**
- Close: Click outside, press Escape, or click launcher again
- Search: Type to filter, shows desktop files + frequent apps
- Launch: Click or press Enter

### Quick Settings Dropdown

**Triggered:** Click system tray area on shelf

**Layout:**
```
┌──────────────────────────────────┐
│  󰖩 WiFi: Home Network     [>]    │  Expandable sections
│  󰕾 Volume                 ====   │  Slider controls
│  󰃟 Brightness             ====   │  Slider controls
│   Bluetooth: Off          [ ]   │  Toggle switches
│   Night Light             [ ]   │
│   Do Not Disturb          [ ]   │
├──────────────────────────────────┤
│  [] Perf  [•] Balanced  [] Save │  Power profiles
├──────────────────────────────────┤
│  󰐥 Power  󰒲 Settings  󰌾 Lock    │  Action buttons
└──────────────────────────────────┘
```

**Features:**
- Width: 360px, drops down from system tray (right-aligned)
- Expandable items: WiFi shows networks, Audio shows device picker
- Interactive sliders: Volume, brightness with percentage
- Toggle switches: Bluetooth, Night Light, Do Not Disturb
- Power profiles: Performance, Balanced, Power Save
- Action buttons: Power menu, Settings, Lock screen

### Notification Center

**Position:** Separate panel below Quick Settings or accessible separately

**Features:**
- Grouped by app with timestamps
- Inline media controls for music (MPRIS)
- Action buttons for interactive notifications
- Swipe/click to dismiss
- Same Material You card styling as Quick Settings

---

## Color System: Material You Implementation

### Dynamic Color Generation Pipeline

```
Wallpaper Image
    ↓
Extract dominant color (source color)
    ↓
Generate 5 key colors:
  • Primary (main brand color)
  • Secondary (complementary accent)
  • Tertiary (third accent)
  • Error (alerts/warnings)
  • Neutral (surfaces/backgrounds)
    ↓
Each key color → 13 tonal values (0-100 lightness)
    ↓
Map tones to 65+ semantic tokens:
  • surface, surfaceVariant, surfaceContainer
  • onSurface, onSurfaceVariant
  • primary, onPrimary, primaryContainer
  • secondary, tertiary, error tokens...
    ↓
Export to multiple formats:
  • SCSS for AGS
  • CSS variables for GTK
  • Conf files for Hyprland
  • JSON for structured access
  • Shell variables for scripts
```

### Color Token Structure (Dark Mode Example)

```scss
// Generated from wallpaper
$md-source: #4285f4;

// Surface colors (backgrounds)
$md-surface: #1c1b1f;                  // Base dark background
$md-surface-container: #211f26;        // Cards, panels
$md-surface-container-high: #2b2930;   // Elevated surfaces
$md-surface-container-highest: #36343b;

// Primary accent (wallpaper-derived)
$md-primary: #b0c6ff;                  // Light blue in dark mode
$md-on-primary: #00315c;               // Text on primary
$md-primary-container: #004a7c;        // Button backgrounds

// Secondary, tertiary, error...
$md-secondary: #bfc6dc;
$md-tertiary: #dbbce0;
$md-error: #ffb4ab;

// Text colors
$md-on-surface: #e4e1e6;               // Primary text
$md-on-surface-variant: #c7c5d0;       // Secondary text
$md-outline: #918f9a;                  // Borders, dividers
```

### Wallpaper Auto-Rotation

**Configuration:**
- **Source:** `~/.config/wallpapers/` directory
- **Interval:** Hourly (configurable)
- **Extraction method:** Vibrant color algorithm
- **Dark/light toggle:** Manual + auto-switch (sunrise/sunset times)

**Update Flow:**
1. Timer triggers wallpaper change (or manual selection)
2. Hyprpaper loads new image
3. AGS service extracts dominant color via material-color-utilities
4. Generates full Material You palette (65+ tokens)
5. Exports to SCSS, CSS, conf, JSON, shell formats
6. AGS hot-reloads styles (< 100ms)
7. Triggers sync script to update Hyprland, Kitty, Neovim, etc.
8. Smooth 300ms color transition

### System-wide Color Propagation

**Components that consume generated colors:**
- **AGS widgets** - Direct SCSS import
- **Hyprland** - Border colors via conf file
- **Kitty terminal** - Color scheme via generated conf
- **Starship prompt** - Dynamic palette TOML
- **Neovim** - Auto-generated colorscheme
- **GTK4 apps** - CSS variables
- **Hyprlock** - Lock screen colors
- **SDDM** - Login screen theme

**Sync mechanism:**
- AGS service emits signal on color change
- `sync-colors.sh` script propagates to all components
- Hot-reload where possible (Kitty, Hyprland)
- Next-launch update for others (GTK apps, Neovim)

---

## Lock Screen Design (Hyprlock)

### Visual Layout

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                   │
│                  [Wallpaper with blur + dim]                     │
│                                                                   │
│  14:30                                                           │
│  Monday, February 24                                             │
│                                                                   │
│                         [User Avatar]                            │
│                         John Doe                                 │
│                                                                   │
│                    ┌──────────────────────┐                      │
│                    │ Enter password...    │                      │
│                    └──────────────────────┘                      │
│                                                                   │
│              Or enter PIN:  [1][2][3]                           │
│                            [4][5][6]                            │
│                            [7][8][9]                            │
│                            [←][0][✓]                            │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Key Features

- **Background:** Current wallpaper with 3-pass blur + 40% dim
- **Time/Date:** Top-left, large Material You typography
- **User avatar:** Centered with Material You primary border
- **Password field:** Material You input with outline states
- **PIN pad:** On-demand 3×4 grid overlay (slides up from bottom)
- **Authentication:** Both password and PIN supported
- **Notifications:** Minimal cards bottom-right (app + count only)
- **Media controls:** Compact controls if music playing

---

## Login Screen Design (SDDM)

### Visual Layout

```
┌─────────────────────────────────────────────────────────────────┐
│                  [Wallpaper with blur + tint]                    │
│                                                                   │
│         ┌─────────────────────────────────────────┐             │
│         │  [Avatar]  [Avatar]  [Avatar]  [+Add]   │             │
│         │   John      Jane      Guest              │             │
│         │                                           │             │
│         │         ┌─────────────────────┐          │             │
│         │         │ Password...         │          │             │
│         │         └─────────────────────┘          │             │
│         │                                           │             │
│         │         [Login] or [Use PIN]            │             │
│         │                                           │             │
│         └─────────────────────────────────────────┘             │
│                                                                   │
│   Session:  Hyprland ▼          ⏻  ⏲  ⏾                        │
└─────────────────────────────────────────────────────────────────┘
```

### Components

**Background:**
- Wallpaper with 40px blur
- Surface color tint at 30% opacity
- Frosted glass effect

**Login Card:**
- 480px width, centered
- Surface container background (95% opacity)
- 24px border radius, 8dp elevation shadow

**User Carousel:**
- Horizontal scrollable list
- 80px circular avatars
- Active user: Primary border + scale 1.1
- Smooth scroll animation

**Authentication:**
- Password field: 56px height, Material You styling
- Login button: Primary container, pill-shaped (24px radius)
- PIN option: Text button that opens PIN pad overlay

**Session Selector:**
- Bottom-left dropdown with Material You menu
- Lists available sessions (Hyprland, GNOME, etc.)

**Power Actions:**
- Bottom-right icon buttons (48×48dp)
- Shutdown, Reboot, Suspend with confirmation dialogs

---

## Implementation Strategy

### Phase 1: Foundation Setup
1. Create `ags/` module directory structure
2. Install dependencies (AGS, Node.js, TypeScript, material-color-utilities)
3. Set up build system (package.json, tsconfig.json)
4. Create basic AGS config skeleton

### Phase 2: Color System
1. Implement color extraction service
2. Create Material You palette generator
3. Build color export system (SCSS, CSS, conf, JSON, shell)
4. Test color generation with sample wallpapers

### Phase 3: Core Widgets
1. Build top shelf widget (launcher, apps, workspaces, system tray)
2. Create full-screen app launcher
3. Implement quick settings dropdown
4. Add notification center

### Phase 4: Services Integration
1. Network management service (nmcli wrapper)
2. Audio service (WirePlumber/PipeWire)
3. Bluetooth service
4. Power profiles service
5. Wallpaper rotation service

### Phase 5: Lock & Login Screens
1. Rewrite hyprlock configuration with Material You colors
2. Create SDDM Material You theme (QML components)
3. Implement PIN pad support for both screens

### Phase 6: System Integration
1. Propagate colors to Kitty terminal
2. Update Starship prompt with dynamic palette
3. Generate Neovim Material You colorscheme
4. Apply GTK4 theming
5. Update Hyprland border colors

### Phase 7: Migration & Cleanup
1. Remove waybar module
2. Remove swaync module
3. Update Hyprland autostart (remove waybar/swaync, add AGS)
4. Update config.yaml module definitions
5. Test complete system on clean boot

---

## Dependencies

### System Packages (ags/deps.yaml)

```yaml
packages:
  arch:
    - ags                          # Aylur's GTK Shell
    - nodejs
    - npm
    - typescript
    - dart-sass
    - imagemagick
    - libnotify
    - networkmanager
    - wireplumber
    - bluez
    - power-profiles-daemon
    - polkit-gnome

npm:
  - "@girs/gtk-4.0"
  - "@girs/glib-2.0"
  - "@material/material-color-utilities"
  - "colorthief"
  - "sharp"
  - "chokidar"

script:
  - run: |
      if ! command -v ags &>/dev/null; then
        git clone --depth=1 https://github.com/Aylur/ags.git /tmp/ags
        cd /tmp/ags
        meson setup build
        meson install -C build
      fi
    provides: ags
```

---

## Migration Checklist

### Files to Remove
- `waybar/.config/waybar/` (all configs and scripts)
- `swaync/.config/swaync/` (all configs)
- `waybar/deps.yaml` entries for waybar, swaync

### Files to Create
- `ags/` (entire new module with full structure)
- `ags/deps.yaml`
- `hyprlock/` (rewrite with Material You config)
- `sddm/themes/material-you/` (custom QML theme)

### Files to Modify
- `hyprland/.config/hypr/hyprland.conf` (update exec-once, source colors)
- `kitty/.config/kitty/kitty.conf` (add color include)
- `starship/.config/starship.toml` (dynamic palette)
- `nvim/.config/nvim/init.lua` (add material-you colorscheme)
- `config.yaml` (add ags module, update hyprland deps, remove waybar/swaync)

---

## Success Criteria

### Functional Requirements
- ✅ AGS replaces waybar, swaync, rofi for all UI interactions
- ✅ Dynamic colors regenerate from wallpaper changes
- ✅ Wallpaper auto-rotates hourly from configured folder
- ✅ Quick settings provides full system control (audio, network, bluetooth, brightness, power)
- ✅ Lock screen supports both password and PIN authentication
- ✅ SDDM theme matches system Material You colors
- ✅ All applications (terminal, editor, compositor) use generated colors

### Non-functional Requirements
- ✅ Color changes apply system-wide in < 500ms
- ✅ UI feels responsive (< 100ms interaction feedback)
- ✅ Design is cohesive across all components
- ✅ System is stable (no crashes, memory leaks)
- ✅ Configuration is maintainable (clear structure, good documentation)

### User Experience
- ✅ ChromeOS-like aesthetics with Material You polish
- ✅ Clean, minimal, modern appearance
- ✅ Glassy, translucent effects where appropriate
- ✅ Smooth animations and transitions
- ✅ Intuitive interactions (familiar patterns)

---

## References

- [Material Design 3 Color System](https://m3.material.io/styles/color/overview)
- [Material Color Utilities](https://github.com/material-foundation/material-color-utilities)
- [ChromeOS Material You Implementation](https://9to5google.com/2022/06/15/chromeos-material-you-dynamic-colors/)
- [AGS Documentation](https://aylur.github.io/ags-docs/)
- [ChromeOS Quick Settings Redesign](https://chromeunboxed.com/chromeos-quick-settings-material-you-redesign-first-look)
- [Hyprland Status Bars Wiki](https://wiki.hypr.land/Useful-Utilities/Status-Bars/)
