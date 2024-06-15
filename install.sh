#!/usr/bin/env bash

has() {
    command -v "$1" 1>/dev/null 2>&1
}

path_add() {
    f_path=$1
    if [ -d "$f_path" ] && [[ ":$PATH:" != *":$f_path:"* ]]; then
        export PATH="${PATH:+"$PATH:"}$f_path"
    fi
}

required() {
    cmd=$1
    if ! has "$cmd"; then
        echo "[ERROR] $cmd is required."
        exit 1
    fi
}

ensure_homebrew() {
    if ! has brew; then
        if ! NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/null; 
        then
            echo "[ERROR] Homebrew installation failed."
            exit 1
        fi
    fi
}

link() {
    source=$1
    destination=$2

    if [ -f "$destination" ] || [ -d "$destination" ]; then
        # if the destination file or directory exists and is not a symlink, create a backup
        if [ ! -L "$destination" ]; then
            # Get the basename of the file or directory
            dest_base=$(basename "$destination")
            # Backup file or directory name
            dest_bak="$HOME/.cache/dotfiles/$dest_base.bak"
            echo "[INFO] backup $destination"
            mkdir -p "$HOME/.cache/dotfiles"
            mv "$destination" "$dest_bak"
        else
            # if the destination is a symlink, remove the symlink
            echo "[INFO] unlink $destination"
            rm "$destination"
        fi
    fi
    parent_dir=$(dirname "$destination")
    mkdir -p "$parent_dir"
    ln -sfn "$source" "$destination"
    echo "[OK] linked $source <-> $destination"
}

required "git"
required "curl"
required "gcc"

# Ensure homebrew is installed
ensure_homebrew

# Adding homebrew bin directory to PATH
path_add "/opt/homebrew/bin"
path_add "/home/linuxbrew/.linuxbrew/bin"

# Adding local "bin" directories to PATH
path_add "/usr/local/bin"
path_add "$HOME/.local/bin"
path_add "$HOME/bin"

# Install starship prompt
if  has brew && ! has starship; then
    brew install starship
fi

# Adding both bashenv and zshenv to the home directory
link "$PWD/shell/env" "$HOME/.bashenv"
link "$PWD/shell/env" "$HOME/.zshenv"

# Adding both bashrc and zshrc to the home directory
link "$PWD/shell/bash/.bashrc" "$HOME/.bashrc"
link "$PWD/shell/zsh/.zshrc" "$HOME/.zshrc"

CONFIG_DIR="${XDG_CONFIG_HOME:-"$HOME/.config"}"

# Adding ssh configuration to $HOME/ssh
link "$PWD/ssh/config" "$HOME/.ssh/config"
link "$PWD/ssh/allowed_signers" "$HOME/.ssh/allowed_signers"

# Adding direnv configuration to $XDG_CONFIG_HOME/direnv/direnv.toml
link "$PWD/direnv/direnv.toml" "$CONFIG_DIR/direnv/direnv.toml"
link "$PWD/direnv/direnvrc" "$CONFIG_DIR/direnv/direnvrc"

# Adding git configuration to $XDG_CONFIG_HOME/git
link "$PWD/git/.gitignore" "$CONFIG_DIR/git/.gitignore"
link "$PWD/git/commit-template.txt" "$CONFIG_DIR/git/commit-template.txt"

# Adding alacritty configuration to $XDG_CONFIG_HOME/alacritty
link "$PWD/alacritty/alacritty.toml" "$CONFIG_DIR/alacritty/alacritty.toml"

# Adding tmux configuration to $XDG_CONFIG_HOME/tmux
link "$PWD/tmux/tmux.conf" "$CONFIG_DIR/tmux/tmux.conf"