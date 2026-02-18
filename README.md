# Dotfiles Repository

A modular, well-documented dotfiles repository using GNU Stow for flexible deployment across multiple machines.

## ✨ Features

- **🔧 Modular Design** - Pick and choose which configurations to deploy
- **🔐 1Password Integration** - SSH agent and git signing with 1Password
- **🐚 Multiple Shells** - Bash, Zsh (with Starship prompt), and Fish configurations
- **⚡ Modern Tools** - Git, direnv, Hyprland, Kitty, Rofi, and more
- **📦 Easy Deployment** - GNU Stow for safe, reversible installations
- **📚 Comprehensive Documentation** - Every module fully documented
- **🤖 Automated Setup** - Bootstrap script for fresh installations

---

## 🚀 Quick Start

### Automated Installation (Recommended)

```bash
git clone <repo-url> ~/.local/share/dotfiles
cd ~/.local/share/dotfiles
./bootstrap.sh
```

The bootstrap script will:
- Auto-detect your Linux distribution
- Install required dependencies (stow, yq, zsh, git, curl)
- Backup any existing configuration files
- Install zsh plugins and FZF
- Deploy your dotfiles using GNU Stow
- Set zsh as your default shell

**Supported environments:** Arch Linux, Debian/Ubuntu, Fedora/RHEL, GitHub Codespaces

### Post-Installation Setup

After deployment, configure machine-specific settings:

```bash
# Configure Git with SSH keys from GitHub
configure-git-machine <your-github-username>

# Verify Git configuration
git-setup-verify

# Log out and back in to use your new shell
exec zsh
```

---

## 📦 What's Included

### Shell Configuration

- **[Bash](docs/modules/bash.md)** - Basic Bash configuration with sensible defaults
- **[Zsh](docs/modules/zsh.md)** - Advanced Zsh with Starship prompt, plugins, and FZF
- **[Fish](docs/modules/fish.md)** - Modern Fish shell with Fisher plugins and Starship prompt
- **[Starship](docs/modules/starship.md)** - Unified prompt with cyberpunk Tokyo Night theme

### Development Tools

- **[Git](docs/modules/git.md)** ⭐ - Comprehensive Git configuration with:
  - SSH-based commit signing (1Password integration)
  - 30+ useful aliases
  - Better diff/merge algorithms
  - Global gitignore and commit templates
  - Automated setup script: `configure-git-machine`

- **[Direnv](docs/modules/direnv.md)** - Environment variable management with 1Password secrets

### Desktop Environment

- **[Hyprland](docs/modules/hyprland.md)** - Modern tiling Wayland compositor
- **[Rofi](docs/modules/rofi.md)** - Application launcher and menu system
- **[Kitty](docs/modules/kitty.md)** - GPU-accelerated terminal emulator
- **[WayVNC](docs/modules/wayvnc.md)** - VNC server for Wayland

### Integration Guides

- **[1Password Integration](docs/1password-integration.md)** 🔐 - Complete guide for SSH, Git, and secrets management

---

## 📖 Documentation

Complete documentation is available in the [`docs/`](docs/) directory:

- **[Full Documentation Index](docs/index.md)** - Complete documentation hub
- **[Module Documentation](docs/modules/)** - Detailed docs for each module
- **[Repository Structure](docs/structure.md)** - Understanding the layout
- **[Publishing to GitHub Pages](docs/PUBLISHING.md)** - Host docs online

### Quick Links

- **[Keyboard Shortcuts](docs/keyboard-shortcuts.md)** 🎹 - All keybindings reference
- [Git Module](docs/modules/git.md) - Git configuration and signing
- [Zsh Module](docs/modules/zsh.md) - Shell environment setup
- [1Password Integration](docs/1password-integration.md) - Security setup

---

## 📁 Repository Structure

```
dotfiles/
├── config.yaml           # Module configuration
├── install.sh            # GNU Stow deployment script
├── bootstrap.sh          # Automated setup for fresh systems
├── README.md             # This file
├── CLAUDE.md            # AI assistant instructions
│
├── docs/                 # Complete documentation (GitHub Pages ready)
│   ├── index.md          # Documentation hub
│   ├── modules/          # Module-specific documentation
│   ├── _config.yml       # Jekyll configuration
│   └── ...
│
├── bash/                 # Bash configuration
├── zsh/                  # Zsh configuration
├── fish/                 # Fish shell configuration
├── starship/             # Starship prompt (cyberpunk Tokyo Night)
├── git/                  # Git configuration
│   ├── .gitconfig        # Main git config
│   ├── .config/git/      # Global gitignore, templates
│   └── .local/bin/       # Git utility scripts
├── direnv/               # Direnv configuration
├── hyprland/             # Hyprland compositor config
├── kitty/                # Kitty terminal config
├── rofi/                 # Rofi launcher config
└── wayvnc/               # WayVNC server config
```

### Module Structure

Each module follows a consistent structure:

```
module-name/
├── .config/              # XDG config files (~/.config/)
├── .local/               # User-local files (~/.local/)
│   └── bin/              # Executable scripts
├── .stow-local-ignore    # Files excluded from deployment
└── [dotfiles]            # Files deployed directly to $HOME
```

---

## 🔧 Manual Installation

If you prefer manual control or the bootstrap script doesn't work:

### Prerequisites

```bash
# Debian/Ubuntu
sudo apt-get install stow yq

# Arch Linux
sudo pacman -S stow yq

# macOS with Homebrew
brew install stow yq
```

### Deployment

```bash
# Clone the repository
git clone <repo-url> ~/.local/share/dotfiles
cd ~/.local/share/dotfiles

# Deploy all configured modules
./install.sh

# Or deploy specific modules manually
cd git && stow -t "$HOME" .
cd zsh && stow -t "$HOME" .
```

### Post-Installation

```bash
# Configure Git with automated script
configure-git-machine <github-username>

# Or install Zsh tools manually
~/.local/bin/configure-zsh-plugins
~/.local/bin/configure-fzf
```

---

## ⚙️ Customization

### Adding/Removing Modules

Edit `config.yaml` to control which modules are deployed:

```yaml
modules:
  - name: "git"
    path: "git"
    hosts:
      - local

  - name: "zsh"
    path: "zsh"
    hosts:
      - local
      - name: work
        target: "$HOME/.work"
```

### Machine-Specific Overrides

Use `.gitconfig.local` for machine-specific git settings:

```bash
# Copy the example
cp ~/.config/git/gitconfig.local.example ~/.gitconfig.local

# Or use the automated setup
configure-git-machine <github-username>
```

Edit `~/.gitconfig.local` to override:
- Email addresses (work vs personal)
- Editor preferences
- Signing keys
- Custom aliases

---

## 🎯 Common Tasks

### Setting Up a New Machine

```bash
# 1. Clone and bootstrap
git clone <repo-url> ~/.local/share/dotfiles
cd ~/.local/share/dotfiles
./bootstrap.sh

# 2. Configure Git
configure-git-machine <github-username>

# 3. Verify setup
git-setup-verify

# 4. Restart shell
exec zsh
```

### Adding a New Module

```bash
# 1. Create module directory
mkdir new-module
cd new-module

# 2. Add your dotfiles
mkdir -p .config/new-module
echo "config" > .config/new-module/config.conf

# 3. Create .stow-local-ignore
cat > .stow-local-ignore << 'EOF'
README\.md
.*\.md$
EOF

# 4. Add to config.yaml
yq -i '.modules += [{"name": "new-module", "path": "new-module", "hosts": ["local"]}]' config.yaml

# 5. Document in docs/modules/new-module.md

# 6. Deploy
cd .. && ./install.sh
```

### Updating Existing Configurations

```bash
# Edit files in their module directories
vim zsh/.zshrc

# Changes are immediately reflected (symlinks)
# Restart shell if needed
exec zsh

# Commit changes
git add zsh/.zshrc
git commit -m "feat(zsh): update configuration"
git push
```

---

## 🔒 Security Features

- **SSH commit signing** with 1Password integration
- **Secret management** via direnv and 1Password
- **Global gitignore** prevents committing sensitive files
- **Machine-specific configs** not version controlled
- **Automated key import** from GitHub

See [1Password Integration Guide](docs/1password-integration.md) for complete setup.

---

## 📚 Learning Resources

- **[GNU Stow Manual](https://www.gnu.org/software/stow/manual/)** - Understanding deployment
- **[XDG Base Directory Spec](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)** - Config file standards
- **[Dotfiles Best Practices](https://dotfiles.github.io/)** - Community resources
- **[Conventional Commits](https://www.conventionalcommits.org/)** - Commit message format

---

## 🤝 Contributing

When modifying this repository:

1. **Document thoroughly** - Update module documentation
2. **Follow conventions** - Use established directory structure
3. **Test deployment** - Verify with `./install.sh`
4. **Update this README** - Keep the overview current
5. **Use conventional commits** - Follow commit message format

---

## 🌐 Publishing Documentation

Documentation is configured for GitHub Pages. To publish:

1. Push to GitHub
2. Go to Settings → Pages
3. Source: `main` branch, `/docs` folder
4. Save

See [PUBLISHING.md](docs/PUBLISHING.md) for detailed instructions.

---

## 📄 License

Personal dotfiles - use as you wish.

---

**Maintained by:** Anirudh Aggarwal
**Documentation:** [docs/index.md](docs/index.md)
**GitHub Pages:** (configure in repository settings)
