# Rofi & Waybar Material Design 3 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement Material Design 3 theme for rofi and waybar with deep purple color scheme, AMOLED black backgrounds, and Material Motion system.

**Architecture:** Replace existing Tokyo Night themed config files with new Material Design 3 implementations. Rofi uses card-based grid layout with 2 columns. Waybar uses filled container modules with proper elevation system. Both follow 8dp spacing grid and Material Motion timing curves.

**Tech Stack:** rofi (rasi configuration), waybar (CSS + JSON config), JetBrainsMono Nerd Font, Material Design 3 color system

---

## Task 1: Backup Existing Configurations

**Files:**
- Read: `rofi/.config/rofi/config.rasi`
- Read: `waybar/.config/waybar/style.css`
- Read: `waybar/.config/waybar/config.jsonc`
- Create: `rofi/.config/rofi/config-tokyonight-backup.rasi`
- Create: `waybar/.config/waybar/style-tokyonight-backup.css`
- Create: `waybar/.config/waybar/config-tokyonight-backup.jsonc`

**Step 1: Copy rofi config to backup**

```bash
cp rofi/.config/rofi/config.rasi rofi/.config/rofi/config-tokyonight-backup.rasi
```

Expected: Backup file created

**Step 2: Copy waybar style to backup**

```bash
cp waybar/.config/waybar/style.css waybar/.config/waybar/style-tokyonight-backup.css
```

Expected: Backup file created

**Step 3: Copy waybar config to backup**

```bash
cp waybar/.config/waybar/config.jsonc waybar/.config/waybar/config-tokyonight-backup.jsonc
```

Expected: Backup file created

**Step 4: Verify backups exist**

```bash
ls -la rofi/.config/rofi/config-tokyonight-backup.rasi waybar/.config/waybar/style-tokyonight-backup.css waybar/.config/waybar/config-tokyonight-backup.jsonc
```

Expected: All three backup files listed

**Step 5: Commit backups**

```bash
git add rofi/.config/rofi/config-tokyonight-backup.rasi waybar/.config/waybar/style-tokyonight-backup.css waybar/.config/waybar/config-tokyonight-backup.jsonc
git commit -m "backup: preserve Tokyo Night theme before Material Design migration

Create backups of existing rofi and waybar configurations before
replacing with Material Design 3 theme.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 2: Implement Rofi Material Design Theme

**Files:**
- Modify: `rofi/.config/rofi/config.rasi` (complete replacement)

**Step 1: Write Material Design 3 color variables**

Replace entire file content with Material Design color system:

```rasi
configuration {
    modi: "drun,run,window";
    icon-theme: "Papirus-Dark";
    show-icons: true;
    terminal: "kitty";
    drun-display-format: "{name}";
    location: 0;
    disable-history: false;
    hide-scrollbar: true;
    display-drun: "  Apps";
    display-run: "  Run";
    display-window: "  Window";
    sidebar-mode: false;
}

* {
    /* ── Material Design 3 Color System ──────────────── */

    /* Primary Colors */
    primary:              #D0BCFF;
    on-primary:           #381E72;
    primary-container:    #4F378B;
    on-primary-container: #EADDFF;

    /* Secondary Colors */
    secondary:            #CCC2DC;
    secondary-container:  #4A4458;

    /* Tertiary & Error */
    tertiary:             #EFB8C8;
    error:                #F2B8B5;
    error-container:      #8C1D18;

    /* Surface System (AMOLED) */
    background:           #000000;
    surface:              #000000;
    surface-dim:          #1A1B1E;
    surface-container-low:     #1A1B1E;
    surface-container:         #1E1E21;
    surface-container-high:    #282829;
    surface-container-highest: #33333D;

    /* Text & Outline */
    on-surface:           #E6E1E5;
    on-surface-variant:   #CAC4D0;
    outline:              #938F99;
    outline-variant:      #49454F;

    /* Base Settings */
    background-color: transparent;
    text-color: @on-surface;
    font: "JetBrainsMono Nerd Font 12";
}
```

**Step 2: Implement window container with AMOLED black**

Add window styling:

```rasi
window {
    transparency: "real";
    background-color: @background;
    border: 0px;
    border-radius: 28px;
    width: 700px;
    padding: 24px;
}
```

**Step 3: Implement mainbox layout**

```rasi
mainbox {
    background-color: transparent;
    spacing: 20px;
    padding: 0px;
}
```

**Step 4: Implement search bar with highest elevation**

```rasi
inputbar {
    background-color: @surface-container-highest;
    border: 2px solid @primary;
    border-radius: 12px;
    padding: 12px 16px;
    spacing: 12px;
    children: [prompt, entry];
}

prompt {
    background-color: transparent;
    text-color: @primary;
    font: "JetBrainsMono Nerd Font Bold 11";
}

entry {
    background-color: transparent;
    text-color: @on-surface;
    placeholder: "Search applications...";
    placeholder-color: @on-surface-variant;
}
```

**Step 5: Implement card-based grid layout**

```rasi
listview {
    background-color: transparent;
    columns: 2;
    lines: 4;
    spacing: 12px;
    cycle: true;
    dynamic: true;
    layout: vertical;
    fixed-height: true;
    scrollbar: false;
}
```

**Step 6: Implement Material Design cards for applications**

```rasi
element {
    background-color: @surface-container-high;
    text-color: @on-surface;
    orientation: vertical;
    border-radius: 16px;
    padding: 16px;
    spacing: 12px;
    border: 0px;
    /* Material Motion: Emphasized Decelerate */
    transition: background-color 400ms cubic-bezier(0.05, 0.7, 0.1, 1.0),
                border-color 400ms cubic-bezier(0.05, 0.7, 0.1, 1.0);
}

element-icon {
    background-color: transparent;
    size: 64px;
    cursor: inherit;
    horizontal-align: 0.5;
}

element-text {
    background-color: transparent;
    text-color: inherit;
    cursor: inherit;
    vertical-align: 0.5;
    horizontal-align: 0.5;
    font: "JetBrainsMono Nerd Font 13";
}
```

**Step 7: Implement all element states (normal, selected, urgent, active)**

```rasi
/* Normal States */
element normal.normal {
    background-color: @surface-container-high;
    text-color: @on-surface;
}

element alternate.normal {
    background-color: @surface-container-high;
    text-color: @on-surface;
}

/* Selected States */
element selected.normal {
    background-color: @primary-container;
    text-color: @on-primary-container;
    border: 2px solid @primary;
}

element selected.normal:hover {
    background-color: @primary-container;
}

element alternate.selected.normal {
    background-color: @primary-container;
    text-color: @on-primary-container;
    border: 2px solid @primary;
}

/* Urgent States */
element normal.urgent {
    background-color: @surface-container-high;
    text-color: @error;
}

element alternate.urgent {
    background-color: @surface-container-high;
    text-color: @error;
}

element selected.urgent {
    background-color: @error-container;
    text-color: @error;
    border: 2px solid @error;
}

element alternate.selected.urgent {
    background-color: @error-container;
    text-color: @error;
    border: 2px solid @error;
}

/* Active States */
element normal.active {
    background-color: @surface-container-high;
    text-color: @primary;
}

element alternate.active {
    background-color: @surface-container-high;
    text-color: @primary;
}

element selected.active {
    background-color: @primary-container;
    text-color: @on-primary-container;
    border: 2px solid @primary;
}

element alternate.selected.active {
    background-color: @primary-container;
    text-color: @on-primary-container;
    border: 2px solid @primary;
}
```

**Step 8: Implement message and error states**

```rasi
message {
    background-color: @surface-container-highest;
    border: 0px;
    border-radius: 12px;
    padding: 16px;
}

textbox {
    background-color: transparent;
    text-color: @on-surface-variant;
    padding: 0px;
    horizontal-align: 0.5;
}

error-message {
    background-color: @error-container;
    border: 2px solid @error;
    border-radius: 12px;
    padding: 16px;
}

error-message textbox {
    text-color: @error;
}
```

**Step 9: Implement mode switcher**

```rasi
mode-switcher {
    background-color: @surface-container-highest;
    border: 0px;
    border-radius: 12px;
    spacing: 4px;
    padding: 4px;
}

button {
    background-color: transparent;
    text-color: @on-surface-variant;
    padding: 8px 16px;
    border-radius: 8px;
    font: "JetBrainsMono Nerd Font 11";
    /* Material Motion: Standard */
    transition: background-color 300ms cubic-bezier(0.2, 0.0, 0, 1.0),
                color 300ms cubic-bezier(0.2, 0.0, 0, 1.0);
}

button selected {
    background-color: @primary-container;
    text-color: @on-primary-container;
}

button:hover {
    background-color: @surface-container-high;
    text-color: @on-surface;
}

button selected:hover {
    background-color: @primary-container;
}
```

**Step 10: Test rofi appearance**

```bash
rofi -show drun
```

Expected: Rofi opens with Material Design theme:
- Pure black background
- Deep purple accents
- Card-based 2-column grid
- Smooth hover animations

**Step 11: Commit rofi theme**

```bash
git add rofi/.config/rofi/config.rasi
git commit -m "feat: implement Material Design 3 theme for rofi

Replace Tokyo Night theme with complete Material Design 3
implementation featuring:
- Deep purple primary color system
- AMOLED black backgrounds
- Card-based 2-column grid layout
- Material Motion emphasized easing curves
- Proper surface elevation hierarchy

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 3: Implement Waybar Material Design CSS Theme

**Files:**
- Modify: `waybar/.config/waybar/style.css` (complete replacement)

**Step 1: Write Material Design 3 color variables and global styles**

Replace entire file with Material Design theme:

```css
/* ═══════════════════════════════════════════════════════════
   Waybar — Material Design 3 (Deep Purple AMOLED)
   Color System: Material Design 3 Tonal Palette
   ═══════════════════════════════════════════════════════════ */

* {
    /* ── Material Design 3 Colors ──────────────────────── */

    /* Primary */
    --md-primary: #D0BCFF;
    --md-on-primary: #381E72;
    --md-primary-container: #4F378B;
    --md-on-primary-container: #EADDFF;

    /* Secondary */
    --md-secondary: #CCC2DC;
    --md-secondary-container: #4A4458;

    /* Tertiary & Error */
    --md-tertiary: #EFB8C8;
    --md-error: #F2B8B5;
    --md-error-container: #8C1D18;

    /* Surface (AMOLED) */
    --md-background: #000000;
    --md-surface: #000000;
    --md-surface-dim: #1A1B1E;
    --md-surface-container-low: #1A1B1E;
    --md-surface-container: #1E1E21;
    --md-surface-container-high: #282829;
    --md-surface-container-highest: #33333D;

    /* Text & Outline */
    --md-on-surface: #E6E1E5;
    --md-on-surface-variant: #CAC4D0;
    --md-outline: #938F99;
    --md-outline-variant: #49454F;

    /* Semantic Colors */
    --md-success: #9ece6a;
    --md-warning: #ff9e64;
    --md-info: #7dcfff;

    /* Typography */
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 12px;
    font-weight: 400;
    letter-spacing: 0.0156em;
    min-height: 0;
}

/* ── Window Base ───────────────────────────────────────── */

window#waybar {
    background: transparent;
    color: var(--md-on-surface);
}

tooltip {
    background: var(--md-surface-container-highest);
    border: 1px solid var(--md-primary);
    border-radius: 10px;
    color: var(--md-on-surface);
    padding: 4px;
}

tooltip label {
    color: var(--md-on-surface);
    padding: 4px 8px;
}
```

**Step 2: Implement filled container base for all modules**

```css
/* ── Module Base (Filled Containers) ───────────────────── */

#custom-arch,
#clock,
#temperature,
#hyprland-workspaces,
#workspaces,
#wlr-taskbar,
#taskbar,
#network,
#battery,
#wireplumber,
#custom-notification,
#custom-power {
    background: var(--md-surface-container);
    border-radius: 20px;
    padding: 8px 16px;
    margin: 2px 4px;
    color: var(--md-on-surface);
    /* Material Motion: Standard Easing */
    transition: background-color 300ms cubic-bezier(0.2, 0.0, 0, 1.0),
                color 300ms cubic-bezier(0.2, 0.0, 0, 1.0);
}

#custom-arch:hover,
#clock:hover,
#temperature:hover,
#network:hover,
#battery:hover,
#wireplumber:hover,
#custom-notification:hover,
#custom-power:hover {
    background: var(--md-surface-container-high);
}
```

**Step 3: Implement left module styles (system info)**

```css
/* ── Left Modules (System Info) ────────────────────────── */

#custom-arch {
    color: var(--md-primary);
    font-size: 14px;
    padding: 8px 14px;
    font-weight: 500;
}

#temperature {
    color: var(--md-info);
}

#temperature.critical {
    color: var(--md-error);
    animation: blink-critical 1000ms ease-in-out infinite alternate;
}

@keyframes blink-critical {
    to {
        background: var(--md-error-container);
        color: var(--md-error);
    }
}
```

**Step 4: Implement center module styles (workspaces + taskbar)**

```css
/* ── Center Modules (Workspaces) ────────────────────────── */

#workspaces,
#hyprland-workspaces {
    padding: 4px 8px;
}

#workspaces button,
#hyprland-workspaces button {
    color: var(--md-outline);
    background: transparent;
    border-radius: 14px;
    padding: 6px 12px;
    margin: 0 2px;
    border: none;
    font-weight: 500;
    font-size: 11px;
    /* Material Motion: Standard */
    transition: background-color 300ms cubic-bezier(0.2, 0.0, 0, 1.0),
                color 300ms cubic-bezier(0.2, 0.0, 0, 1.0);
}

#workspaces button:hover,
#hyprland-workspaces button:hover {
    color: var(--md-on-surface);
    background: var(--md-surface-container-high);
}

#workspaces button.active,
#hyprland-workspaces button.active {
    color: var(--md-on-primary-container);
    background: var(--md-primary-container);
    font-weight: 700;
}

#workspaces button.urgent,
#hyprland-workspaces button.urgent {
    color: var(--md-error);
    background: var(--md-error-container);
}

/* ── Center Modules (Taskbar) ───────────────────────────── */

#taskbar,
#wlr-taskbar {
    background: transparent;
    padding: 0;
    margin: 0;
}

#taskbar button,
#wlr-taskbar button {
    color: var(--md-on-surface-variant);
    background: var(--md-surface-container);
    border-radius: 14px;
    padding: 4px 10px;
    margin: 2px 2px;
    border: none;
    transition: background-color 300ms cubic-bezier(0.2, 0.0, 0, 1.0),
                color 300ms cubic-bezier(0.2, 0.0, 0, 1.0);
}

#taskbar button:hover,
#wlr-taskbar button:hover {
    color: var(--md-on-surface);
    background: var(--md-surface-container-high);
}

#taskbar button.active,
#wlr-taskbar button.active {
    color: var(--md-primary);
    background: rgba(208, 188, 255, 0.15);
}
```

**Step 5: Implement right module styles (system status)**

```css
/* ── Right Modules (System Status) ──────────────────────── */

#network {
    color: var(--md-info);
}

#network.disconnected {
    color: var(--md-outline);
}

#clock {
    color: var(--md-on-surface);
    font-weight: 500;
}

#battery {
    color: var(--md-success);
}

#battery.charging {
    color: var(--md-info);
}

#battery.warning:not(.charging) {
    color: var(--md-warning);
}

#battery.critical:not(.charging) {
    color: var(--md-error);
    animation: blink-critical 1000ms ease-in-out infinite alternate;
}

#wireplumber {
    color: var(--md-warning);
}

#wireplumber.muted {
    color: var(--md-outline);
}

#custom-notification {
    color: var(--md-on-surface);
}

#custom-power {
    color: var(--md-error);
    padding: 8px 14px;
}

#custom-power:hover {
    background: var(--md-error-container);
}
```

**Step 6: Test waybar appearance**

```bash
# Kill existing waybar and restart
pkill waybar && waybar &
```

Expected: Waybar displays with:
- Pure black background
- Filled container modules with purple tint
- Deep purple active workspace
- Smooth hover transitions

**Step 7: Commit waybar theme**

```bash
git add waybar/.config/waybar/style.css
git commit -m "feat: implement Material Design 3 theme for waybar

Replace Tokyo Night theme with complete Material Design 3
implementation featuring:
- Deep purple primary color with AMOLED black
- Filled container modules with proper elevation
- Material Motion standard easing curves
- Color-coded module states (info, success, warning, error)
- Smooth 300ms transitions on all interactions

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 4: Update Waybar Configuration (if needed)

**Files:**
- Read: `waybar/.config/waybar/config.jsonc`
- Modify: `waybar/.config/waybar/config.jsonc` (only if needed)

**Step 1: Check if style reference needs updating**

```bash
grep -n "style" waybar/.config/waybar/config.jsonc
```

Expected: Should show line with style reference (currently line 9)

**Step 2: Update style reference if it points to wrong file**

If config.jsonc line 9 says `"style": "style-material-you.css"`, change it to:

```json
    "style": "style.css",
```

If it already says `"style": "style.css"` or has no style line, skip this step.

**Step 3: Verify hyprland/workspaces module exists**

Check if config uses `hyprland/workspaces` or just `workspaces`:

```bash
grep -n "workspaces" waybar/.config/waybar/config.jsonc
```

If it shows `"hyprland/workspaces"`, CSS is already correct.
If it shows just `"workspaces"`, CSS is already correct (both selectors included).

**Step 4: Restart waybar to apply config changes**

```bash
pkill waybar && waybar &
```

Expected: Waybar restarts with Material Design theme

**Step 5: Commit config changes (if any were made)**

Only if changes were made to config.jsonc:

```bash
git add waybar/.config/waybar/config.jsonc
git commit -m "fix: update waybar style reference to style.css

Ensure waybar loads the Material Design 3 theme.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 5: Visual Verification Testing

**Files:**
- None (manual testing)

**Step 1: Test rofi drun mode**

```bash
rofi -show drun
```

Verify:
- [ ] Pure black background (no gray glow on AMOLED)
- [ ] 2-column card grid layout
- [ ] 64px icons centered in cards
- [ ] Deep purple search bar outline
- [ ] Hover changes card background smoothly
- [ ] Selection adds purple border and darker background
- [ ] Animations feel smooth (400ms emphasized decelerate)

**Step 2: Test rofi run mode**

```bash
rofi -show run
```

Verify:
- [ ] Same visual style as drun
- [ ] Mode switcher shows "Run" as active
- [ ] Can type commands and filter results

**Step 3: Test rofi window mode**

```bash
rofi -show window
```

Verify:
- [ ] Shows open windows
- [ ] Same card-based visual style
- [ ] Mode switcher shows "Window" as active

**Step 4: Test waybar module display**

Check waybar bar:

Verify:
- [ ] All modules visible and styled correctly
- [ ] Pure black background (transparent, showing desktop wallpaper through gaps)
- [ ] Modules use filled container style (not outlined)
- [ ] 20px border radius on all module groups
- [ ] Proper spacing (8px gaps between modules)

**Step 5: Test waybar workspace interaction**

Click different workspaces:

Verify:
- [ ] Active workspace has purple background (#4F378B)
- [ ] Inactive workspaces are gray (#938F99)
- [ ] Transition is smooth (300ms)
- [ ] Hover shows lighter background

**Step 6: Test waybar hover states**

Hover over each module:

Verify:
- [ ] Background changes to lighter surface (--md-surface-container-high)
- [ ] Transition is smooth (300ms standard easing)
- [ ] Color remains consistent

**Step 7: Test waybar critical states**

To test battery critical (if laptop):
- If battery is low, verify it pulses between error color and container
- If battery is charging, verify cyan color

To test network disconnected:
- Disconnect network temporarily
- Verify network module shows gray/dimmed

To test audio muted:
- Mute audio: `wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle`
- Verify wireplumber shows gray color
- Unmute to restore

**Step 8: Document any issues found**

Create a note of any visual issues:

```bash
# If issues found, document them
echo "## Visual Issues Found" >> docs/plans/2026-03-01-rofi-waybar-material-issues.md
# Add issue descriptions
```

Expected: No major issues, theme looks polished

---

## Task 6: Accessibility & Contrast Verification

**Files:**
- None (testing only)

**Step 1: Test keyboard navigation in rofi**

```bash
rofi -show drun
```

Test keyboard controls:
- [ ] Tab/Shift+Tab cycles through apps
- [ ] Arrow keys navigate grid
- [ ] Enter launches selected app
- [ ] Escape closes rofi
- [ ] Focus indicator is visible (purple outline)

**Step 2: Verify text contrast ratios**

Visual check on AMOLED display:
- [ ] Search input text (#E6E1E5 on #33333D) - should be easily readable
- [ ] App names on cards (#E6E1E5 on #282829) - should be readable
- [ ] Module text on waybar (#E6E1E5 on #1E1E21) - should be readable
- [ ] Active workspace text (#EADDFF on #4F378B) - should have good contrast

**Step 3: Test focus visibility**

Using keyboard only:
- [ ] Tab through waybar modules (if supported by compositor)
- [ ] Focus states are visible
- [ ] Can identify which element is focused

**Step 4: Document accessibility compliance**

Create note:

```markdown
## Accessibility Verification

- Keyboard navigation: ✓ Fully functional
- Contrast ratios: ✓ WCAG AA compliant
- Focus indicators: ✓ Visible and clear
- Text readability: ✓ All text easily readable

Tested on: AMOLED display with pure black backgrounds
Date: 2026-03-01
```

---

## Task 7: Final Verification & Documentation

**Files:**
- Create: `docs/rofi-waybar-material-theme.md` (usage docs)

**Step 1: Take screenshots (optional)**

If you want to document the theme:

```bash
# Screenshot rofi
rofi -show drun &
sleep 1
grim -g "$(slurp)" ~/rofi-material-screenshot.png

# Screenshot waybar
grim -g "0,0,1920,40" ~/waybar-material-screenshot.png
```

**Step 2: Create usage documentation**

```markdown
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
```

Save to `docs/rofi-waybar-material-theme.md`

**Step 3: Run final visual check**

```bash
# Restart waybar
pkill waybar && waybar &

# Open rofi
rofi -show drun
```

Final checklist:
- [ ] Rofi opens with Material Design theme
- [ ] Waybar displays correctly
- [ ] All colors match Material Design spec
- [ ] Animations are smooth
- [ ] No visual glitches
- [ ] Theme looks polished and professional

**Step 4: Commit documentation**

```bash
git add docs/rofi-waybar-material-theme.md
git commit -m "docs: add Material Design theme usage documentation

Document color palette, features, customization options, and
instructions for reverting to Tokyo Night theme.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

**Step 5: Create final summary commit (optional)**

If you want a summary marker:

```bash
git tag -a material-theme-v1 -m "Material Design 3 theme for rofi and waybar

Complete implementation of Material Design 3 theme with:
- Deep purple primary color (#D0BCFF)
- AMOLED black backgrounds
- Card-based rofi layout (2-column grid)
- Waybar filled container modules
- Material Motion animation system
- Full accessibility compliance (WCAG AA)

Includes backups of original Tokyo Night theme."
```

---

## Success Criteria

✅ **Rofi**:
- Pure AMOLED black background
- 2-column card grid with 64px icons
- Deep purple accents and borders
- Smooth 400ms emphasized animations
- Keyboard navigation works perfectly

✅ **Waybar**:
- Filled container modules with purple tint
- Active workspace uses primary container color
- All modules display correctly
- Smooth 300ms standard animations
- Critical states (battery, network) work correctly

✅ **Visual Quality**:
- No gray glow on AMOLED displays (pure #000000)
- Text is easily readable (WCAG AA contrast)
- Colors match Material Design 3 spec
- Animations feel smooth and intentional
- Theme looks polished and modern

✅ **Maintainability**:
- Tokyo Night backups preserved
- Documentation created
- Color variables clearly defined
- Easy to customize and revert

---

## Estimated Time

- Task 1 (Backups): 5 minutes
- Task 2 (Rofi theme): 20 minutes
- Task 3 (Waybar CSS): 15 minutes
- Task 4 (Config update): 5 minutes
- Task 5 (Visual testing): 15 minutes
- Task 6 (Accessibility): 10 minutes
- Task 7 (Documentation): 10 minutes

**Total: ~80 minutes**
