# Dotfiles Repository

This repository contains your personal dotfiles and a simple installer that uses **GNU Stow** to deploy them to your system.

## Directory Layout
```
├── config.yaml      # Installation configuration
├── install.sh       # Shell script to perform the install
├── bash/           # Bash related dotfiles (e.g. .bashrc)
├── vim/            # Vim related dotfiles (e.g. .vimrc)
├── zsh/            # Zsh related dotfiles (e.g. .zshrc)
└── README.md
```

## Prerequisites
* **GNU Stow** – package name `stow`.
* **yq** – command‑line YAML processor (for parsing `config.yaml`).

Install them on Debian/Ubuntu:
```
sudo apt-get install stow yq
```
On macOS with Homebrew:
```
brew install stow yq
```

## Usage
1. Clone this repository to a temporary location:
```
git clone <repo-url> dotfiles
cd dotfiles
```
2. Run the installer:
```
./install.sh
```
The script reads `config.yaml`, resolves the module directories, and uses `stow` to link the dotfiles into the target host directories.

## Customizing
Edit `config.yaml` to add or remove modules, or change the host mapping. The script supports two built‑in hosts:
* `local` – deploy to `$HOME`.
* `work` – deploy to `$HOME/.work` (you can add more hosts by extending the `case` statement in `install.sh`).

## Documentation
See the `docs/` folder for detailed explanations of each module.
