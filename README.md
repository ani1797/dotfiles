# Dotfiles Repository

This repository contains your personal dotfiles and a simple installer that uses **GNU Stow** to deploy them to your system.

## Quick Start

Automated setup on a fresh system (requires internet connection):

```bash
git clone <repo-url> ~/.local/share/dotfiles
cd ~/.local/share/dotfiles
./bootstrap.sh
```

The bootstrap script will:
- Auto-detect your Linux distribution
- Install required dependencies (stow, yq, zsh, git, curl)
- Backup any existing configuration files
- Install Oh-My-Zsh, Powerlevel10k, zsh plugins, and FZF
- Deploy your dotfiles using GNU Stow
- Set zsh as your default shell (except in Codespaces)

**Supported environments:** Arch Linux, Debian/Ubuntu, Fedora/RHEL, and GitHub Codespaces

After installation, log out and back in (or run `exec zsh`) to start using your configured shell.

## Directory Layout
```
├── config.yaml      # Installation configuration
├── install.sh       # Shell script to perform the install
├── bash/           # Bash related dotfiles (e.g. .bashrc)
├── vim/            # Vim related dotfiles (e.g. .vimrc)
├── zsh/            # Zsh related dotfiles (e.g. .zshrc)
└── README.md
```

## Manual Installation

If you prefer manual control or the bootstrap script doesn't work for your system:

### Prerequisites
* **GNU Stow** – package name `stow`.
* **yq** – command‑line YAML processor (for parsing `config.yaml`).

Install them on Debian/Ubuntu:
```bash
sudo apt-get install stow yq
```
On macOS with Homebrew:
```bash
brew install stow yq
```

### Usage
1. Clone this repository:
```bash
git clone <repo-url> dotfiles
cd dotfiles
```
2. Run the installer:
```bash
./install.sh
```
The script reads `config.yaml`, resolves the module directories, and uses `stow` to link the dotfiles into the target host directories.

3. Optionally install zsh tools (Oh-My-Zsh, Powerlevel10k, plugins, FZF):
```bash
~/.local/bin/configure-oh-my-zsh
~/.local/bin/configure-powerlevel10k
~/.local/bin/configure-zsh-plugins
~/.local/bin/configure-fzf
```

## Customizing
Edit `config.yaml` to add or remove modules, or change the host mapping. The script supports two built‑in hosts:
* `local` – deploy to `$HOME`.
* `work` – deploy to `$HOME/.work` (you can add more hosts by extending the `case` statement in `install.sh`).

## Documentation
See the `docs/` folder for detailed explanations of each module.
