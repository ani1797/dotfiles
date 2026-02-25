---
layout: default
title: "FZF Fuzzy Finder"
parent: Modules
---

# FZF Module

Command-line fuzzy finder with Tokyo Night theme and multi-shell integration.

## Features

- **Tokyo Night Theme** - cyberpunk colors matching starship prompt
- **Multi-Shell Support** - bash, zsh, and fish integration
- **System Keybindings** - Ctrl+R (history), Ctrl+T (files), Alt+C (directories)
- **Graceful Degradation** - works without errors if fzf not installed
- **Self-Contained** - all config in fzf module, no external dependencies

## Deployment

```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh
```

This deploys:
- `~/.config/bash/40-fzf.bash` - bash integration
- `~/.config/zsh/40-fzf.zsh` - zsh integration
- `~/.config/fish/conf.d/40-fzf.fish` - fish integration

## Color Scheme

Tokyo Night theme matching starship prompt:

| Element | Color | Hex |
|---------|-------|-----|
| Foreground | Light gray | #c0caf5 |
| Background | Dark Tokyo Night | #1a1b26 |
| Highlight | Magenta | #bb9af7 |
| Selection | Cyan | #7dcfff |
| Info | Blue | #7aa2f7 |
| Marker | Green | #9ece6a |

## Keybindings

### Bash & Zsh

- `Ctrl+R` - Search command history
- `Ctrl+T` - Search files in current directory
- `Alt+C` - Change directory via fuzzy search

### Fish

- `Ctrl+R` - Search command history
- `Ctrl+F` - Search directories (if fzf.fish installed)
- `Ctrl+G` - Search git log (if fzf.fish installed)
- `Ctrl+S` - Search git status (if fzf.fish installed)

## Customization

### Change Colors

Edit the `FZF_DEFAULT_OPTS` in:
- `fzf/.config/bash/40-fzf.bash`
- `fzf/.config/zsh/40-fzf.zsh`
- `fzf/.config/fish/conf.d/40-fzf.fish`

### Add Preview Commands

Add to `FZF_DEFAULT_OPTS`:

```bash
--preview 'bat --color=always --style=numbers --line-range=:500 {}'
```

### Change Default Command

Set in your shell config:

```bash
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
```

## Dependencies

Installed via `fzf/deps.yaml`:

```yaml
packages:
  arch:    [fzf]
  debian:  [fzf]
  fedora:  [fzf]
  macos:   [fzf]

requires:
  - fzf
```

The `requires` field ensures fzf binary is available before stowing config files.

## Troubleshooting

### Keybindings not working

Check if fzf keybindings sourced:

```bash
# Bash
type __fzf_history__

# Zsh
whence fzf-history-widget

# Fish
type fzf_key_bindings
```

### Colors not applied

Check FZF_DEFAULT_OPTS is set:

```bash
echo $FZF_DEFAULT_OPTS
```

Should show Tokyo Night color configuration.

### Fish integration not loading

Check if fzf is available and file is sourced:

```fish
type -q fzf && echo "fzf available" || echo "fzf not found"
set -q __FISH_FZF_LOADED && echo "fzf config loaded" || echo "not loaded"
```

## Integration with Other Tools

### Git Integration

fzf works with git commands:

```bash
git log --oneline | fzf --preview 'git show {1}'
git branch | fzf --preview 'git log --oneline {1}'
```

### Yazi File Manager

The yazi module includes fzf integration for fuzzy file finding within yazi.

### Vim/Neovim

fzf.vim plugin provides fuzzy file finding in vim/neovim (not included in this module).

## References

- [fzf GitHub](https://github.com/junegunn/fzf)
- [fzf.fish plugin](https://github.com/PatrickF1/fzf.fish)
- [Tokyo Night Theme](https://github.com/tokyo-night/tokyo-night-vscode-theme)
