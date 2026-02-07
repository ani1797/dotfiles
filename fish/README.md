# Fish Shell Configuration Module

Portable, modular fish shell configuration that works across multiple Linux distributions using fish-native features.

## Features

- **Fish-native design** - Uses conf.d/, fish_add_path, fisher
- **Automatic loading** - Fish auto-sources conf.d/*.fish files
- **Graceful degradation** - Works without optional plugins
- **Distro-specific aliases** - Arch, Debian/Ubuntu, Fedora/RHEL support
- **CachyOS integration** - Loads CachyOS config on CachyOS systems
- **Fisher plugin management** - Declarative plugins via fish_plugins

## Deployment

```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh
```

This deploys:
- `~/.config/fish/config.fish` - minimal entry point
- `~/.config/fish/fish_plugins` - plugin declarations
- `~/.config/fish/conf.d/*.fish` - modular configuration files
- `~/.local/bin/configure-*` - helper scripts

## Module Load Order

Fish automatically sources files in `conf.d/` alphabetically:

- `00-environment.fish` - PATH and environment variables (loads first)
- `aliases-arch.fish` - Arch Linux specific (if on Arch)
- `aliases-debian.fish` - Debian/Ubuntu specific (if on Debian)
- `aliases-fedora.fish` - Fedora/RHEL specific (if on Fedora)
- `aliases-universal.fish` - Cross-platform aliases
- `60-direnv.fish` - Direnv integration (if direnv installed)
- `cachyos.fish` - CachyOS integration (if on CachyOS)

## Optional Tool Installation

Helper scripts in `~/.local/bin/`:

```bash
# Install Fisher and plugins
configure-fisher

# Configure Tide prompt
configure-tide
```

## Plugins Included

Managed via `fish_plugins` and installed with `configure-fisher`:

- **fisher** - Plugin manager
- **nvm.fish** - Node version manager
- **tide** - Modern, customizable prompt
- **z** - Smart directory jumping

## Machine-Specific Overrides

Create `~/.config/fish/config.local.fish` for machine-specific customizations not managed by stow:

```fish
# Example: work machine proxy
set -gx HTTP_PROXY http://proxy.example.com:8080
set -gx HTTPS_PROXY http://proxy.example.com:8080
```

## Customization

### Add New Distro Support

Create `fish/.config/fish/conf.d/aliases-<distro>.fish`:

```fish
if test -f /etc/<distro>-release
    alias update='sudo <package-manager> update'
    # ... more aliases
end
```

### Add Personal Aliases

Edit `fish/.config/fish/conf.d/aliases-universal.fish` or create `~/.config/fish/config.local.fish`

### Add Plugins

Edit `fish/.config/fish/fish_plugins`, add plugin repo, run `configure-fisher`

## Fish-Native Features

This configuration uses fish idioms:

- `fish_add_path` - Add directories to PATH
- `set -gx` - Export global variables
- `set -q VAR; or set -gx VAR value` - Set if not already set
- `test` - Conditionals (instead of `[[]]`)
- `function/end` - Define functions
- `conf.d/` - Automatic module loading

## Troubleshooting

### Check what modules loaded
```bash
ls ~/.config/fish/conf.d/*.fish
```

### Test syntax of all files
```bash
for f in ~/.config/fish/conf.d/*.fish; fish -n $f && echo "✓ $f"; end
```

### Verify distro detection
```bash
ls /etc/*-release
```

### Check if fisher is installed
```fish
type -q fisher && echo "Fisher OK" || echo "Fisher missing"
```

## References

- [Fish Shell Documentation](https://fishshell.com/docs/current/)
- [Fisher Plugin Manager](https://github.com/jorgebucaran/fisher)
- [Tide Prompt](https://github.com/IlanCosman/tide)
- [nvm.fish](https://github.com/jorgebucaran/nvm.fish)
