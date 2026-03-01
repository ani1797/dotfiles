# Rofi & Waybar Material Design Theme

**Date**: 2026-03-01
**Status**: Design Approved
**Design System**: Material Design 3 (Material You)

## Overview

Complete redesign of rofi and waybar configurations using authentic Material Design 3 principles. This replaces the existing Tokyo Night theme with a modern, clean material design aesthetic featuring deep purple as the primary color, pure AMOLED black backgrounds, and proper Material Design motion system.

## Design Goals

1. **Authentic Material Design 3**: Follow Google's Material Design 3 specifications for color, typography, spacing, and motion
2. **AMOLED Optimization**: Pure black backgrounds for OLED displays with high contrast colored elements
3. **Modern Card-Based UI**: Use Material Design cards and filled containers for a contemporary look
4. **Smooth Animations**: Implement Material Motion system with emphasized easing curves
5. **Accessibility**: Meet WCAG AA contrast standards, proper focus indicators

## Color System

### Design Rationale

Material Design 3 uses a scientific tonal palette system where colors are generated in 13 tonal variations (0-100). This ensures proper contrast ratios and visual harmony across all UI states.

### Core Color Roles

- **Primary**: `#D0BCFF` (light purple for main interactive elements)
- **On-Primary**: `#381E72` (dark purple text on primary)
- **Primary Container**: `#4F378B` (filled button backgrounds, active states)
- **On-Primary-Container**: `#EADDFF` (text on primary containers)

### Supporting Colors

- **Secondary**: `#CCC2DC` (complementary pink-purple for secondary actions)
- **Secondary Container**: `#4A4458` (secondary filled elements)
- **Tertiary**: `#EFB8C8` (pink accent for highlights and special states)
- **Error**: `#F2B8B5` (soft red for errors/warnings)
- **Error Container**: `#8C1D18` (error background)

### Surface System (AMOLED)

- **Background**: `#000000` (pure black)
- **Surface**: `#000000` (base surface, pure black)
- **Surface-Dim**: `#1A1B1E` (slightly lighter for sunken areas)
- **Surface-Container-Low**: `#1A1B1E` (lowest elevation, subtle lift)
- **Surface-Container**: `#1E1E21` (standard containers - waybar modules)
- **Surface-Container-High**: `#282829` (elevated containers - rofi cards)
- **Surface-Container-Highest**: `#33333D` (highest elevation, modals, search bar)

### Text & Outline Colors

- **On-Surface**: `#E6E1E5` (primary text)
- **On-Surface-Variant**: `#CAC4D0` (secondary text, icons)
- **Outline**: `#938F99` (borders, dividers)
- **Outline-Variant**: `#49454F` (subtle dividers)

### Purple Tinting

All surface containers include ~5% purple tint mixed into the grays to maintain Material Design's characteristic color harmonization and brand presence.

## Architecture

### Rofi Application Launcher

#### Layout Structure

**Card-Based Grid**:
- 2-column grid layout
- Card dimensions: Auto-height, equal width
- Each card displays: centered icon (64px) + app name below
- Grid spacing: 12dp between cards

**Main Window**:
- Background: Pure black (`#000000`)
- Width: 700px
- Auto-height based on content
- Border radius: 28dp (Material Design large container)
- Padding: 24dp from all edges

**Search Bar** (top):
- Background: Surface-Container-Highest (`#33333D`)
- Outline: 2px Primary color
- Border radius: 12dp
- Height: 24dp + padding (12dp vertical, 16dp horizontal)
- Contains: Primary-colored prompt icon + search input

**Card Design**:
- Background: Surface-Container-High (`#282829` + purple tint)
- Border radius: 16dp (Material Design card standard)
- Padding: 16dp internal
- Hover state: Elevate to brighter surface
- Selected state: Primary outline (2px) + Primary-Container background

#### Component Breakdown

```
window
├── mainbox
│   ├── inputbar
│   │   ├── prompt (icon, Primary color)
│   │   └── entry (search text, On-Surface)
│   ├── listview (2-column grid)
│   │   └── element (cards)
│   │       ├── element-icon (64px, centered)
│   │       └── element-text (app name)
│   └── message (error/no results)
```

### Waybar Status Bar

#### Module Organization

**Left Section**: System Info
- Arch logo (system indicator, launches rofi)
- Temperature (CPU thermal status)

**Center Section**: Workspace Management
- Hyprland workspaces (numbered indicators)
- wlr/taskbar (active application icons)

**Right Section**: System Status
- Network (connection status)
- Clock (time/date)
- Battery (charge level)
- Notifications (swaync integration)
- Power menu (shutdown/logout)

#### Module Styling

**Filled Container Approach**:
- Each module group uses Surface-Container background (`#1E1E21` + purple tint)
- Border radius: 20dp (modern, friendly)
- Padding: 8dp vertical, 16dp horizontal
- Margin: 8dp between groups, 8dp from screen edges

**States**:
- **Normal**: Surface-Container background, On-Surface text
- **Hover**: Surface-Container-High background (lighter)
- **Active** (workspaces): Primary-Container background, On-Primary-Container text
- **Critical** (battery low): Error color text with pulse animation
- **Disabled** (muted, disconnected): Outline color at 60% opacity

#### Component Breakdown

```
waybar
├── modules-left
│   ├── custom/arch (filled pill)
│   └── temperature (filled pill)
├── modules-center
│   ├── hyprland/workspaces (filled pill container)
│   │   └── workspace buttons
│   └── wlr/taskbar (filled pill container)
│       └── app buttons
└── modules-right
    ├── network (filled pill)
    ├── clock (filled pill)
    ├── battery (filled pill)
    ├── custom/notification (filled pill)
    └── custom/power (filled pill)
```

## Motion & Interaction Design

### Material Motion Curves

Material Design uses specific easing functions that mimic natural motion physics.

**Standard Easing** (general transitions):
```css
cubic-bezier(0.2, 0.0, 0, 1.0)
Duration: 300ms
```
Use for: color changes, opacity transitions, simple state changes

**Emphasized Decelerate** (incoming elements):
```css
cubic-bezier(0.05, 0.7, 0.1, 1.0)
Duration: 400ms
```
Use for: hover states, appearing elements, elevation changes
Behavior: Starts fast, slows dramatically (settling into place)

**Emphasized Accelerate** (outgoing elements):
```css
cubic-bezier(0.3, 0.0, 0.8, 0.15)
Duration: 200ms
```
Use for: dismissing elements, closing animations
Behavior: Starts slow, accelerates rapidly (quick exit)

### Rofi Interactions

| Interaction | Animation | Duration | Curve |
|-------------|-----------|----------|-------|
| Card hover | Background → Surface-Container-Highest | 400ms | Emphasized decelerate |
| Card selection | Add Primary outline + Primary-Container bg | 400ms | Emphasized decelerate |
| Search focus | Outline → Primary (2px) | 300ms | Standard |
| Type/filter | Instant update | 0ms | None |
| Window appear | Fade in + scale from 0.95 | 400ms | Emphasized decelerate |
| Window dismiss | Fade out + scale to 0.95 | 200ms | Emphasized accelerate |

### Waybar Interactions

| Interaction | Animation | Duration | Curve |
|-------------|-----------|----------|-------|
| Module hover | Surface-Container → High | 300ms | Standard |
| Workspace click | Background → Primary-Container | 300ms | Standard |
| Battery critical | Pulse opacity (infinite) | 1000ms | Ease-in-out |
| Tooltip appear | Fade in (100ms delay) | 250ms | Emphasized decelerate |
| State change | Color transition | 300ms | Standard |

### Accessibility

- **Focus indicators**: 2px Primary outline with 2px offset for keyboard navigation
- **No animations preference**: Respect `prefers-reduced-motion` media query (instant transitions)
- **High contrast**: Maintain minimum 4.5:1 contrast ratio for text
- **Keyboard navigation**: Full support with visible focus states

## Typography & Spacing

### Typography Scale

**Font Family**: JetBrainsMono Nerd Font (existing, monospace with icon support)

**Rofi Type Scale**:
- **Display** (app names): 13px, weight 500, line-height 1.4, letter-spacing 0.0156em
- **Body** (search input): 12px, weight 400, line-height 1.5, letter-spacing 0.0156em
- **Label** (prompt, modes): 11px, weight 500, line-height 1.4, letter-spacing 0.009em

**Waybar Type Scale**:
- **Body** (module text): 12px, weight 400, line-height 1.5, letter-spacing 0.0156em
- **Label** (workspace numbers): 11px, weight 500, line-height 1.4, letter-spacing 0.009em
- **Icons**: 14px (for icon font glyphs)

### Spacing System (8dp Grid)

All spacing follows Material Design's 8-pixel baseline grid for visual rhythm and consistency.

**Rofi Spacing**:
- Window padding: 24dp (24px)
- Card padding: 16dp (16px)
- Card gap: 12dp (12px)
- Search bar padding: 16dp horizontal, 12dp vertical
- Icon-to-text spacing: 12dp
- Window border radius: 28dp
- Card border radius: 16dp
- Input border radius: 12dp

**Waybar Spacing**:
- Module padding: 8dp vertical, 16dp horizontal
- Module gap: 8dp
- Screen margins: 8dp (top, left, right)
- Icon-to-text spacing: 8dp
- Module border radius: 20dp
- Workspace button padding: 6dp vertical, 12dp horizontal
- Workspace button gap: 4dp

### Visual Hierarchy

Text colors establish information hierarchy:
- **Primary content**: On-Surface (`#E6E1E5`) - main text, primary information
- **Secondary content**: On-Surface-Variant (`#CAC4D0`) - supporting text, metadata
- **Disabled/inactive**: Outline (`#938F99`) at 60% opacity - muted states
- **Accent/active**: Primary (`#D0BCFF`) - interactive elements, active states

## Implementation Details

### File Changes

**Rofi**:
1. Backup existing config: `rofi/.config/rofi/config.rasi` → `config-tokyonight-backup.rasi`
2. Create new: `rofi/.config/rofi/config.rasi` with complete Material Design theme

**Waybar**:
1. Backup existing files:
   - `waybar/.config/waybar/style.css` → `style-tokyonight-backup.css`
   - `waybar/.config/waybar/config.jsonc` → `config-tokyonight-backup.jsonc`
2. Replace: `waybar/.config/waybar/style.css` with Material Design theme
3. Update: `waybar/.config/waybar/config.jsonc` (remove style-material-you.css reference, keep module config)

### Dependencies

**Required** (already present):
- rofi - Application launcher
- waybar - Status bar
- JetBrainsMono Nerd Font - Typography
- Papirus-Dark - Icon theme for app icons

**Optional** (enhances experience):
- Hyprland compositor - For blur effects on tooltips
- swaync - Notification center integration

### Edge Cases & Special States

**Rofi Edge Cases**:
- **No search results**: Display "No applications found" message in On-Surface-Variant color, centered
- **Long app names**: Truncate with ellipsis (`text-overflow: ellipsis`) after 20 characters
- **Missing icons**: Fallback to generic application icon from Papirus-Dark theme
- **Urgent windows**: Use Error color (`#F2B8B5`) for text and borders
- **Mode switching**: Smooth transition between drun/run/window modes with 300ms fade

**Waybar Edge Cases**:
- **Network disconnected**: Show "offline" text in Outline color with disconnected icon
- **Battery warning** (20%): Show orange accent color
- **Battery critical** (10%): Error color with infinite pulse animation
- **Audio muted**: Show muted icon in Outline color (dimmed appearance)
- **No notifications**: Show bell icon in On-Surface-Variant (neutral state)
- **Temperature critical** (>80°C): Error color with warning icon
- **Tooltip overflow**: Set max-width with text wrapping enabled

### Visual Consistency Rules

- **All borders**: 2px width for accessibility and visibility
- **All transitions**: Animate background-color, color, border-color, opacity, transform
- **Focus states**: 2px Primary outline with 2px offset (keyboard accessibility)
- **Contrast ratios**: WCAG AA compliance (4.5:1 for normal text, 3:1 for large text/icons)

### Testing Checklist

After implementation, verify:

1. **Rofi Functionality**:
   - [ ] All three modes work (drun, run, window)
   - [ ] Search filtering responds correctly
   - [ ] Icons display for all applications
   - [ ] Card hover states work smoothly
   - [ ] Selection highlight is visible
   - [ ] Keyboard navigation works (arrows, enter, escape)

2. **Waybar Display**:
   - [ ] All modules render correctly
   - [ ] Workspaces show active state
   - [ ] Battery percentage displays
   - [ ] Network status updates
   - [ ] Clock shows correct time/date
   - [ ] Tooltips appear on hover

3. **Visual Quality**:
   - [ ] Colors match Material Design spec
   - [ ] Pure black background on AMOLED (no glow/gray)
   - [ ] Hover animations are smooth
   - [ ] Text is readable with good contrast
   - [ ] Icons are properly sized and aligned

4. **Critical States**:
   - [ ] Battery low warning (20%) shows orange
   - [ ] Battery critical (10%) pulses with error color
   - [ ] Network disconnected shows dimmed state
   - [ ] Audio muted displays correctly
   - [ ] Temperature critical shows error state

5. **Accessibility**:
   - [ ] Keyboard focus is visible
   - [ ] Tab navigation works through all elements
   - [ ] Contrast meets WCAG AA standards
   - [ ] Text is legible at 12px size

## Design Principles Summary

1. **Color Science**: Use Material Design 3 tonal palettes with proper contrast ratios
2. **8dp Grid**: All spacing multiples of 8 (or 4 for fine adjustments)
3. **Material Motion**: Emphasized easing curves for natural, intentional movement
4. **Semantic Typography**: Type scale with clear hierarchy and purpose
5. **Surface Elevation**: Layered surfaces with consistent tinting and elevation system
6. **Accessibility First**: WCAG AA contrast, keyboard navigation, focus indicators
7. **Pure Implementation**: No hybrid compromises, full Material Design 3 compliance

## Next Steps

1. Create implementation plan with detailed file-by-file changes
2. Generate complete color palette CSS variables
3. Implement rofi config.rasi with card-based layout
4. Implement waybar style.css with filled containers
5. Test all interactions and edge cases
6. Document keyboard shortcuts and usage

---

**Design Approved**: 2026-03-01
**Ready for Implementation**: Yes
