---
layout: default
title: "Starship Theme Guide"
---

# Starship Theme: Cyberpunk Tokyo Night

Design document for the Starship prompt theme used across all shells.

## Design Philosophy

The theme draws from **cyberpunk aesthetics** — neon accents floating on dark surfaces, inspired by Tokyo Night color schemes and lofi poolside bar visuals. Each prompt segment is a "pill" — colored text on a dark (`#24283b` storm) background, separated by powerline arrow glyphs that create a flowing bar effect.

**Key principles:**
- **Neon on dark** — bright foreground colors pop against the muted storm background
- **Pill segments** — `[](storm)[ content ](color bg:storm)[](fg:storm)` creates rounded floating blocks
- **Two-line layout** — keeps the input cursor on a clean line
- **Right-aligned metadata** — duration and time stay out of the way
- **Icons over words** — Nerd Font glyphs replace "via", "on", "in"

## Color Palette

All colors are defined once in the `[palettes.tokyo-night]` section:

| Name | Hex | Usage |
|------|-----|-------|
| `night` | `#1a1b26` | Terminal background |
| `storm` | `#24283b` | Pill segment backgrounds |
| `fg` | `#c0caf5` | Default foreground text |
| `comment` | `#565f89` | Muted text (duration, time) |
| `selection` | `#33467c` | Selection highlight |
| `red` | `#f7768e` | Rust, errors, root user |
| `orange` | `#ff9e64` | (reserved for future use) |
| `yellow` | `#e0af68` | Python, git status |
| `green` | `#9ece6a` | Node.js, username/hostname |
| `teal` | `#73daca` | Go |
| `blue` | `#7aa2f7` | Directory, Kubernetes, success prompt |
| `cyan` | `#7dcfff` | Docker |
| `magenta` | `#bb9af7` | Git branch, Terraform, vim mode |

## Pill Segment Anatomy

Each module wraps its content in a pill using powerline glyphs:

```
[](storm)  →  left cap: starts the dark background
[ icon content ](color bg:storm)  →  colored text on dark pill
[](fg:storm)  →  right cap: ends the dark background
```

The `$format` string in `starship.toml` chains pills together. The main format groups directory + git into two connected pills with shared transitions:

```
[](storm) directory [](fg:storm)  [](storm) git [](fg:storm)
```

Language/tool modules each create their own standalone pills when detected.

## Kitty Integration

The theme extends to the terminal emulator for a cohesive look:

| Setting | Value | Purpose |
|---------|-------|---------|
| Font | JetBrainsMono Nerd Font 12pt | Nerd Font icons + powerline glyphs |
| Background opacity | 0.92 | Subtle wallpaper bleed-through |
| Cursor | Beam, 1.5pt, blinking | Cyberpunk cursor feel |
| Tab bar | Powerline slanted | Matches prompt pill aesthetic |
| Window padding | 8px | Breathing room around content |
| Colors | Tokyo Night palette | Same palette as Starship |

## Customization Guide

### Use a different palette

Replace the `[palettes.tokyo-night]` block with your own colors. Keep the same names (`storm`, `blue`, `red`, etc.) and all modules will automatically use the new colors.

Example — Catppuccin Mocha:
```toml
[palettes.catppuccin]
night = "#1e1e2e"
storm = "#313244"
fg = "#cdd6f4"
comment = "#6c7086"
# ... etc
```

Then set `palette = "catppuccin"` at the top.

### Remove pill backgrounds (flat mode)

To switch from pills to flat colored text:

1. Remove `bg:storm` from all `style` values
2. Remove the `[](storm)` and `[](fg:storm)` wrappers from format strings
3. Remove the separator `[ ]()` entries from the main `format`

### Adjust the right prompt

The right prompt shows duration and time. To customize:

```toml
# Show only duration (remove time)
right_format = "$cmd_duration"

# Show nothing on the right
right_format = ""
```

### Add a new language module

Follow this pattern:
```toml
[your_language]
format = "[](storm)[ $symbol$version ](your_color bg:storm)[](fg:storm) "
symbol = "icon "
style = "your_color bg:storm"
```

Then add `$your_language\` to the format string in the layout section.
