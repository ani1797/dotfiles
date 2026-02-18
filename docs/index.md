---
layout: default
title: Home
nav_order: 1
---

# Dotfiles Documentation

Complete documentation for all modules, guides, and configurations in this dotfiles repository.

{: .no_toc }

## Table of Contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Getting Started

New to this repository? Start here:

1. **[Repository README](../README.md)** - Installation instructions and quick start
2. **[Repository Structure](structure)** - All 21 modules at a glance
3. **[Config.yaml Format](../config.yaml)** - Module configuration reference

---

## Module Documentation

### Shell & Prompt

Shells, prompt theming, and shared shell utilities — the core of daily interaction.

#### [Bash](modules/bash)
{: .d-inline-block }
Basic
{: .label .label-blue }

Basic Bash configuration for systems where zsh/fish aren't available.
- `.bashrc` with sensible defaults
- Aliases (`dot`, `set_env`) and prompt
- Compatible with most systems

#### [Zsh](modules/zsh)
{: .d-inline-block }
Advanced
{: .label .label-green }

Advanced Zsh configuration with Starship prompt.
- [Starship](modules/starship) prompt with cyberpunk Tokyo Night theme
- Plugin management (autosuggestions, syntax highlighting, etc.)
- Custom aliases and functions (`~dot`, `set_env`)
- FZF integration
- [1Password](1password-integration) CLI integration

#### [Fish](modules/fish)
{: .d-inline-block }
Advanced
{: .label .label-green }

Modern Fish shell configuration with plugin ecosystem.
- Fisher plugin manager
- Custom functions and abbreviations
- [Starship](modules/starship) prompt with cyberpunk Tokyo Night theme
- Auto-completion and syntax highlighting

#### [Starship](modules/starship)
{: .d-inline-block }
Theme
{: .label .label-yellow }

Unified cross-shell prompt — cyberpunk Tokyo Night theme.
- Neon pill segments on dark backgrounds
- Two-line layout with right-aligned duration/time
- Nerd Font icons, named palette
- See also: [Theme Design Guide](starship-theme)

### Development Tools

Tools and configurations for software development.

#### [Git](modules/git)
{: .d-inline-block }
Essential
{: .label .label-purple }

Comprehensive Git configuration with modern best practices.
- **SSH-based commit signing** with [1Password](1password-integration)
- 30+ useful aliases
- Better diff and merge algorithms
- Global gitignore patterns
- Configuration scripts:
  - `configure-git-machine` - Automated setup for new machines
  - `git-setup-verify` - Verify configuration

#### [Neovim](modules/nvim)
{: .d-inline-block }
Advanced
{: .label .label-green }

Modern Neovim configuration with Lazy.nvim and modular plugins.
- Lazy.nvim plugin manager
- Telescope fuzzy finder, Neo-tree file explorer
- LSP with Mason (auto-installs language servers)
- nvim-cmp completion engine
- Avante AI/Claude integration
- Tokyo Night theme

#### [Tmux](modules/tmux)
{: .d-inline-block }
Essential
{: .label .label-purple }

Terminal multiplexer with intuitive keybindings and session persistence.
- Ctrl+Space prefix key
- Tokyo Night status bar theme
- Alt+Arrow pane navigation (no prefix)
- Vi copy-mode with clipboard integration
- TPM plugin manager, tmux-resurrect

#### [SSH](modules/ssh)
{: .d-inline-block }
Essential
{: .label .label-purple }

Structured SSH configuration with modular host management.
- Base config with `Include config.d/*`
- GitHub host entry (port 443 for firewalls)
- [1Password](1password-integration) SSH agent support
- Permissions setup via `configure-ssh`

#### [Direnv](modules/direnv)
{: .d-inline-block }
Development
{: .label .label-yellow }

Environment variable management for project-specific configurations.
- Automatic environment loading
- `.envrc` file support
- Shell integration ([bash](modules/bash), [zsh](modules/zsh), [fish](modules/fish))
- [1Password](1password-integration) secret management

### Terminal & Desktop

Terminal emulators, Wayland compositor, and desktop tools.

#### [Kitty](modules/kitty)
{: .d-inline-block }
Essential
{: .label .label-purple }

GPU-accelerated terminal emulator with cyberpunk aesthetics.
- JetBrainsMono Nerd Font 12pt
- Tokyo Night color scheme (matches [Starship](modules/starship) palette)
- Split/tiling window management with keybindings
- Powerline slanted tab bar, 0.92 opacity
- See also: [Theme Design Guide](starship-theme#kitty-integration)

#### [Hyprland](modules/hyprland)
Modern tiling Wayland compositor configuration.
- Window management rules
- Workspace configuration
- Keybindings (see [Keyboard Shortcuts](keyboard-shortcuts))
- Animations and effects
- Auto-start applications

#### [Rofi](modules/rofi)
Application launcher and menu system.
- Custom themes
- Launcher modes
- Keybinding integration
- Wayland compatibility

#### [WayVNC](modules/wayvnc)
VNC server for Wayland compositors.
- Network configuration
- Security settings
- Display configuration

### Package Managers & Runtimes

Configuration for language-specific package managers.

#### Npm
npm registry and configuration (`.npmrc`).

#### Pip
pip configuration (`pip.conf`) with index settings.

#### UV
[uv](https://github.com/astral-sh/uv) Python package manager configuration.

#### Podman
Podman container registries and configuration.

#### Fonts
Font packages — JetBrainsMono Nerd Font (used by [Kitty](modules/kitty) and [Starship](modules/starship)).

---

## Guides & References

### [Keyboard Shortcuts](keyboard-shortcuts)
Complete keybinding reference for all modules:
- [Hyprland](modules/hyprland) — window management, workspaces, app launching
- [Neovim](modules/nvim) — Telescope, LSP, completion, AI
- [Tmux](modules/tmux) — splits, panes, windows, copy mode
- [Kitty](modules/kitty) — terminal splits and navigation
- [Git](modules/git) — command aliases

### [1Password Integration](1password-integration)
{: .d-inline-block }
Security
{: .label .label-red }

Cross-module guide for integrating 1Password:
- **SSH Agent** — [SSH module](modules/ssh)
- **Git Signing** — [Git module](modules/git)
- **direnv Secrets** — [Direnv module](modules/direnv)
- **CLI Authentication** — [Zsh](modules/zsh) / [Fish](modules/fish) shell integration

### [Starship Theme Guide](starship-theme)
{: .d-inline-block }
Design
{: .label .label-yellow }

Design document for the cyberpunk Tokyo Night theme:
- Full color palette with hex values
- Pill segment anatomy
- [Kitty](modules/kitty) integration details
- Customization guide (change palette, disable pills, add modules)

---

## Repository Structure

### [Structure Documentation](structure)
All 21 modules organized by category with descriptions.

### Key Files

| File | Purpose |
|------|---------|
| **[config.yaml](../config.yaml)** | Module configuration and deployment targets |
| **[install.sh](../install.sh)** | GNU Stow deployment script |
| **[bootstrap.sh](../bootstrap.sh)** | Automated setup for fresh systems |
| **[CLAUDE.md](../CLAUDE.md)** | Instructions for Claude Code (AI assistant) |

---

## Common Tasks

**Setting up a new machine:**
1. Run `./bootstrap.sh` (automated)
2. Configure git: `configure-git-machine <github-username>`
3. Configure neovim: `configure-nvim`
4. Configure tmux: `configure-tmux`
5. Configure ssh: `configure-ssh`
6. Verify git setup: `git-setup-verify`

**Adding a new module:**
1. Create module directory with [standard structure](structure#module-directory-convention)
2. Add module to `config.yaml`
3. Create `.stow-local-ignore` to exclude docs
4. Document in `docs/modules/<module>.md`
5. Add to this index and [structure.md](structure)
6. Run `./install.sh` to deploy

---

## Local Development

To preview the documentation locally:

```bash
cd docs
bundle install
bundle exec jekyll serve
```

Then visit http://localhost:4000 in your browser.

---

## Additional Resources

- **[GNU Stow Manual](https://www.gnu.org/software/stow/manual/)** - Understanding the deployment tool
- **[XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)** - Standard for config file locations
- **[Dotfiles Best Practices](https://dotfiles.github.io/)** - Community resources
- **[Starship Documentation](https://starship.rs/config/)** - Prompt configuration reference

---

**Last Updated:** 2026-02-18
