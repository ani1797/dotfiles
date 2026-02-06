# Kitty Terminal Configuration

Kitty terminal configuration with Tokyo Night color scheme and tiling window management.

## Features

- **Tokyo Night Color Scheme**: Dark theme matching system-wide aesthetics
  - Background: `#1a1b26`
  - Foreground: `#c0caf5`
  - Accent colors: Blues, purples, and cyans from Tokyo Night palette

- **Tiling Window Management**: Efficient split-based workflow
  - Multiple layout support: splits, stack, tall, grid
  - Visual borders for split identification
  - Active window highlighted with blue border (`#7aa2f7`)

- **Keybindings**:
  - `Ctrl+Shift+\`: Create vertical split
  - `Ctrl+Shift+-`: Create horizontal split
  - `Ctrl+Arrow`: Navigate between splits
  - `Shift+Alt+Arrow`: Move windows between positions
  - `Ctrl+Shift+W`: Close current split
  - `Ctrl+Shift+L`: Cycle through layouts
  - `Ctrl+Shift+R`: Enter resize mode

## Files

- `.config/kitty/kitty.conf` - Main configuration file

## Deployment

Deployed to `~/.config/kitty/` via GNU Stow. The install script creates a symlink from the dotfiles repository to the system configuration location.

```bash
cd ~/.local/share/dotfiles
./install.sh
```

## Customization

For machine-specific settings that shouldn't be version controlled, create `~/.config/kitty/local.conf` and include it in kitty.conf:

```conf
include local.conf
```

The `local.conf` file won't be managed by stow and will remain machine-specific.

## Dependencies

- Kitty terminal emulator

## Configuration Reload

After making changes to the configuration:
- Press `Ctrl+Shift+F5` in an open Kitty window to reload
- Or restart Kitty terminal
