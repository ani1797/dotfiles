---
layout: default
title: "Starship Prompt"
parent: Modules
---

# Starship Prompt Module

Unified, cross-shell prompt using [Starship](https://starship.rs/) with a cyberpunk Tokyo Night theme.

## Features

- **Cross-shell** - Single config works in Bash, Zsh, and Fish
- **Cyberpunk Tokyo Night theme** - Neon pill segments on dark backgrounds
- **Two-line prompt** - Info line + character line for breathing room
- **Right-aligned status** - Command duration and time on the right
- **Nerd Font icons** - Every module gets a distinctive icon
- **Named palette** - All colors defined once, referenced everywhere

## Deployment

```bash
cd ~/.local/share/dotfiles
./install.sh
```

This deploys:
- `~/.config/starship.toml` - Prompt configuration and theme

## Dependencies

- [Starship](https://starship.rs/) - Install via package manager or `curl -sS https://starship.rs/install.sh | sh`
- [JetBrainsMono Nerd Font](https://www.nerdfonts.com/) - Required for icons and powerline glyphs

## Theme

The theme uses a **cyberpunk Tokyo Night** aesthetic with neon-colored text on dark pill-shaped segments. See the [Starship Theme Guide](../starship-theme) for full details.

### Prompt Layout

```
  ~/projects/myapp    main [!?]   v20.11.0                     2s   14:30
❯
```

- **Left**: directory, git, language/tool pills
- **Right**: command duration, clock
- **Second line**: character prompt (`❯` blue on success, red on error)

### Module Colors

| Module | Color | Icon |
|--------|-------|------|
| Directory | Blue | ` ` |
| Git branch | Magenta | ` ` |
| Git status | Yellow | — |
| Python | Yellow | ` ` |
| Node.js | Green | ` ` |
| Rust | Red | ` ` |
| Go | Teal | ` ` |
| Docker | Cyan | ` ` |
| Kubernetes | Blue | `☸ ` |
| Terraform | Magenta | `󱁢 ` |
| Duration | Comment | ` ` |
| Time | Comment | ` ` |

## Customization

### Change colors

Edit the `[palettes.tokyo-night]` section in `starship.toml`. All modules reference palette names, so changing a color there updates it everywhere.

### Disable pills (flat style)

Remove `bg:storm` from module styles and remove the powerline separator characters (``, ``) from format strings.

### Add a module

Follow the pattern of existing modules:
```toml
[your_module]
format = "[](storm)[ $symbol$version ](color bg:storm)[](fg:storm) "
style = "color bg:storm"
```

### Disable time display

```toml
[time]
disabled = true
```

## Shell Integration

Starship is initialized in each shell's config:
- **Zsh**: `zsh/.config/zsh/30-starship.zsh`
- **Fish**: Starship auto-detects fish
- **Bash**: `bash/.config/bash/30-starship.bash` (if present)

## References

- [Starship Configuration](https://starship.rs/config/)
- [Starship Presets](https://starship.rs/presets/)
- [Nerd Fonts Cheat Sheet](https://www.nerdfonts.com/cheat-sheet)
- [Tokyo Night Color Scheme](https://github.com/enkia/tokyo-night-vscode-theme)
