# Dotfiles Documentation

This directory contains comprehensive documentation for the dotfiles management system.

## Quick Start

- **New to this system?** Start with [Installation Guide](installation.md)
- **Creating a module?** See [Module Creation Guide](module-creation.md)
- **Problems?** Check [Troubleshooting](troubleshooting.md)

## Documentation Index

### User Guides

- [Installation Guide](installation.md) - Setting up dotfiles on a new system
- [Module Creation Guide](module-creation.md) - How to create new modules
- [Troubleshooting](troubleshooting.md) - Common issues and solutions

### Reference Documentation

- [deps.yaml Specification](deps-yaml-spec.md) - Complete format reference for module dependencies
- [config.yaml Specification](config-yaml-spec.md) - Complete format reference for system configuration
- [Architecture Overview](architecture.md) - How the dotfiles system works

### Design Documents

- [plans/](plans/) - Design documents and architectural decisions
  - [2026-02-24-self-sufficient-modules-design.md](plans/2026-02-24-self-sufficient-modules-design.md) - Self-sufficient modules redesign

## System Overview

This dotfiles management system uses:

- **GNU Stow** for symlink management
- **YAML** for configuration (config.yaml per machine, deps.yaml per module)
- **Auto-discovery** for modules (any directory with deps.yaml is a valid module)
- **Toolkits** for grouping related modules
- **Machine profiles** for per-host configuration

### Key Concepts

**Module:** A directory containing configuration files and a `deps.yaml` that defines its dependencies. Module name equals directory name.

**Toolkit:** A named group of modules (e.g., "terminal", "dev-tools") for easier machine configuration.

**Machine Profile:** A hostname-to-modules mapping that determines what gets installed on each system.

**Stow Target:** The directory where module files are symlinked (defaults to `$HOME`).

## Quick Reference

### Adding a New Module

```bash
# 1. Create module directory
mkdir my-module

# 2. Add configuration files
echo "config content" > my-module/.config/myapp/config.yaml

# 3. Create deps.yaml
cat > my-module/deps.yaml << 'EOF'
provides: myapp

packages:
  arch: [myapp]
  debian: [myapp]
  macos: [myapp]
EOF

# 4. Add to config.yaml machines section
# Edit config.yaml and add "my-module" to your machine's modules list

# 5. Run installer
./install.sh
```

### File Structure

```
dotfiles/
├── install.sh              # Main installer script
├── config.yaml             # Toolkits and machine profiles
├── docs/                   # Documentation (you are here)
│   ├── README.md
│   ├── installation.md
│   ├── module-creation.md
│   ├── deps-yaml-spec.md
│   ├── config-yaml-spec.md
│   └── plans/
├── bash/                   # Module: bash shell configuration
│   ├── deps.yaml           # Module dependencies
│   ├── .bashrc
│   └── .config/...
├── nvim/                   # Module: Neovim configuration
│   ├── deps.yaml
│   └── .config/nvim/...
└── ... (other modules)
```

## Contributing

When adding new features or making architectural changes:

1. Document the design in `docs/plans/YYYY-MM-DD-topic-design.md`
2. Update relevant specification documents
3. Update user guides if behavior changes
4. Test on all supported platforms (Arch, Debian, macOS)

## Support

For issues, questions, or suggestions, please check:
1. [Troubleshooting](troubleshooting.md) for common issues
2. Existing design documents in [plans/](plans/)
3. The git commit history for context
