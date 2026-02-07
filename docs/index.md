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
2. **[Repository Structure](structure)** - How the dotfiles are organized
3. **[Config.yaml Format](../config.yaml)** - Module configuration reference

---

## Module Documentation

Detailed documentation for each dotfiles module.

### Shell Configuration

Modern shell environments with powerful features and integrations.

#### [Bash](modules/bash)
{: .d-inline-block }
Basic
{: .label .label-blue }

Basic Bash configuration for systems where zsh/fish aren't available.
- `.bashrc` with sensible defaults
- Basic aliases and prompt
- Compatible with most systems

#### [Zsh](modules/zsh)
{: .d-inline-block }
Advanced
{: .label .label-green }

Advanced Zsh configuration with Oh-My-Zsh and Powerlevel10k.
- Oh-My-Zsh framework integration
- Powerlevel10k theme
- Plugin management (autosuggestions, syntax highlighting, etc.)
- Custom aliases and functions
- FZF integration
- 1Password CLI integration

#### [Fish](modules/fish)
{: .d-inline-block }
Advanced
{: .label .label-green }

Modern Fish shell configuration with plugin ecosystem.
- Fisher plugin manager
- Custom functions and abbreviations
- Tide prompt theme
- Auto-completion and syntax highlighting
- Configuration management tools

### Development Tools

Tools and configurations for software development.

#### [Git](modules/git)
{: .d-inline-block }
Essential
{: .label .label-purple }
⭐

Comprehensive Git configuration with modern best practices.
- **SSH-based commit signing** with 1Password
- 30+ useful aliases
- Better diff and merge algorithms
- Global gitignore patterns
- Commit message template
- Configuration scripts:
  - `configure-git-machine` - Automated setup for new machines
  - `git-setup-verify` - Verify configuration
  - `git-create-repo-template` - Initialize new repositories

#### [Direnv](modules/direnv)
{: .d-inline-block }
Development
{: .label .label-yellow }

Environment variable management for project-specific configurations.
- Automatic environment loading
- `.envrc` file support
- Shell integration (bash, zsh, fish)
- 1Password secret management
- Project isolation

### Desktop Environment

Wayland-based desktop environment configuration.

#### [Hyprland](modules/hyprland)
Modern tiling Wayland compositor configuration.
- Window management rules
- Workspace configuration
- Keybindings
- Animations and effects
- Auto-start applications

#### [Rofi](modules/rofi)
Application launcher and menu system.
- Custom themes
- Launcher modes
- Keybinding integration
- Wayland compatibility

#### [Kitty](modules/kitty)
GPU-accelerated terminal emulator.
- Font configuration
- Color schemes
- Keybindings
- Performance optimizations

### Applications

#### [WayVNC](modules/wayvnc)
VNC server for Wayland compositors.
- Network configuration
- Security settings
- Keyboard and mouse input
- Display configuration

---

## Quick Reference Guides

Essential reference documentation for daily use.

### [Keyboard Shortcuts](keyboard-shortcuts) 🎹
Complete keybinding reference for all modules.

**Hyprland shortcuts:**
- Window management and navigation
- Workspace switching
- Application launching
- System controls
- Screenshot and multimedia

**Other modules:**
- Kitty terminal keybindings
- Rofi launcher shortcuts
- Git command aliases

---

## Integration Guides

Cross-module integrations and advanced setups.

### [1Password Integration](1password-integration) 🔐
{: .d-inline-block }
Security
{: .label .label-red }

Complete guide for integrating 1Password across your system.

**Covered topics:**
- **SSH Agent** - Use 1Password for SSH authentication
- **Git Signing** - Sign commits with 1Password-managed keys
- **direnv Integration** - Load secrets from 1Password into environment
- **CLI Authentication** - Authenticate with `op` command
- **Secret Management** - Best practices for managing secrets
- **Troubleshooting** - Common issues and solutions

**Related module docs:**
- [Git module](modules/git) - Git signing configuration
- [Direnv module](modules/direnv) - Environment variable management
- [Zsh module](modules/zsh) - Shell integration

---

## Repository Structure

### [Structure Documentation](structure)
Detailed explanation of the repository layout and conventions.

### Key Files

- **[config.yaml](../config.yaml)** - Module configuration and deployment targets
- **[install.sh](../install.sh)** - GNU Stow deployment script
- **[bootstrap.sh](../bootstrap.sh)** - Automated setup for fresh systems
- **[CLAUDE.md](../CLAUDE.md)** - Instructions for Claude Code (AI assistant)

### Module Structure

Each module follows this structure:
```
module-name/
├── .config/              # XDG config files (~/.config/)
├── .local/               # User-local files (~/.local/)
│   └── bin/              # Executable scripts
├── .stow-local-ignore    # Files to exclude from deployment
└── [direct files]        # Files deployed to $HOME
```

---

## Quick Reference

### Most Useful Resources

1. **[Keyboard Shortcuts](keyboard-shortcuts)** 🎹 - All keybindings in one place
2. **[Git Module](modules/git)** - Modern git workflow with signing
3. **[Zsh Module](modules/zsh)** - Feature-rich shell environment
4. **[1Password Integration](1password-integration)** - Secure secret management

### Common Tasks

**Setting up a new machine:**
1. Run `./bootstrap.sh` (automated)
2. Configure git: `configure-git-machine <github-username>`
3. Verify setup: `git-setup-verify`

**Adding a new module:**
1. Create module directory with appropriate structure
2. Add module to `config.yaml`
3. Create `.stow-local-ignore` to exclude documentation
4. Document in `docs/modules/<module>.md`
5. Run `./install.sh` to deploy

**Updating documentation:**
- Module-specific: Edit `docs/modules/<module>.md`
- Integration guides: Add to `docs/` root
- Update this index if adding new categories

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

## Contributing

When adding or modifying modules:

1. **Document thoroughly** - Each module should have comprehensive documentation
2. **Follow conventions** - Use the established directory structure
3. **Test deployment** - Verify with `./install.sh` before committing
4. **Update index** - Add new documentation to this README

---

## Additional Resources

- **[GNU Stow Manual](https://www.gnu.org/software/stow/manual/)** - Understanding the deployment tool
- **[XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)** - Standard for config file locations
- **[Dotfiles Best Practices](https://dotfiles.github.io/)** - Community resources
- **[Jekyll Documentation](https://jekyllrb.com/docs/)** - Static site generator used for GitHub Pages

---

**Last Updated:** 2026-02-06
