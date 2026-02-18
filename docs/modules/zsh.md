---
layout: default
title: "Zsh Shell"
parent: Modules
---

# Zsh Configuration Module

Portable, modular zsh configuration that works across multiple Linux distributions with graceful degradation.

## Features

- **XDG Base Directory compliant** - configs in `~/.config/zsh/`
- **Graceful degradation** - works without optional plugins/themes
- **Distro-specific aliases** - Arch, Debian/Ubuntu, Fedora/RHEL support
- **Runtime detection** - loads features only if available
- **Helper scripts** - easy installation of optional tools

## Deployment

```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh
```

This deploys:
- `~/.zshrc` - main entry point
- `~/.config/zsh/*.zsh` - modular configuration files
- `~/.local/bin/configure-*` - helper scripts

## Module Load Order

Files in `~/.config/zsh/` load in numbered order:

- `00-environment.zsh` - PATH and environment variables
- `10-history.zsh` - history configuration
- `30-starship.zsh` - Starship prompt integration
- `40-plugins.zsh` - syntax highlighting, autosuggestions (if available)
- `50-aliases-universal.zsh` - cross-platform aliases (`~dot`, `set_env`)
- `51-aliases-arch.zsh` - Arch Linux specific (if on Arch)
- `51-aliases-debian.zsh` - Debian/Ubuntu specific (if on Debian)
- `51-aliases-fedora.zsh` - Fedora/RHEL specific (if on Fedora)
- `52-aliases-docker.zsh` - Docker/Podman aliases
- `60-direnv.zsh` - Direnv integration (if direnv installed)

## Optional Tool Installation

Helper scripts in `~/.local/bin/`:

```bash
# Install zsh plugins (syntax-highlighting, autosuggestions, etc.)
configure-zsh-plugins

# Install FZF fuzzy finder
configure-fzf
```

## Machine-Specific Overrides

Create `~/.zshrc.local` for machine-specific customizations not managed by stow:

```bash
# Example: work machine proxy settings
export HTTP_PROXY="http://proxy.example.com:8080"
export HTTPS_PROXY="http://proxy.example.com:8080"
```

## Customization

### Add New Distro Support

Create `zsh/.config/zsh/51-aliases-<distro>.zsh`:

```bash
# Check for distro-specific file
if [[ -f /etc/<distro>-release ]]; then
  # Define aliases here
  alias update="sudo <package-manager> update"
fi
```

### Add Personal Aliases

Edit `zsh/.config/zsh/50-aliases-universal.zsh` or create `~/.zshrc.local`

### Modify Plugin Load Paths

Edit `zsh/.config/zsh/40-plugins.zsh` to add additional search paths

## Security Features

- Modern `$()` command substitution (not backticks)
- Safe `cleanup()` functions with confirmation prompts
- Interactive prompts before destructive operations
- Fallback values for missing commands

## Troubleshooting

### Check what modules loaded
```bash
ls ~/.config/zsh/*.zsh
```

### Test syntax of all files
```bash
for f in ~/.config/zsh/*.zsh; do zsh -n "$f" && echo "✓ $f"; done
```

### Debug module loading
Add to `~/.zshrc` before the source loop:
```bash
setopt XTRACE  # Enable debug output
```

### Verify distro detection
```bash
# Check which distro-specific file should load
ls /etc/*-release
```

## References

- [Zsh Documentation](http://zsh.sourceforge.net/Doc/)
- [Starship Prompt](https://starship.rs/)
- [XDG Base Directory](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
