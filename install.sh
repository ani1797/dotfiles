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
    src=$1
    dest=$2
    if [ -e "$dest" ]; then
        rm -rv "$dest"
    fi
    ln -s "$src" "$dest"
    echo "[INFO] $src <-> $dest linked."
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

# Adding both bashenv and zshenv to the home directory
link "$PWD/shell/env" "$HOME/.bashenv"
link "$PWD/shell/env" "$HOME/.zshenv"

# Adding both bashrc and zshrc to the home directory
link "$PWD/shell/bash/.bashrc" "$HOME/.bashrc"
link "$PWD/shell/zsh/.zshrc" "$HOME/.zshrc"