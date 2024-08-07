#!/usr/bin/env bash

set -e

 # Check to see if sudo is required for the user
if sudo -v >/dev/null 2>&1; then
    # keep-alive: update existing `sudo` time stamp if set, otherwise do nothing.
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
    _sudo="sudo"
fi

path_add() {
    f_path=$1
    if [ -d "$f_path" ] && [[ ":$PATH:" != *":$f_path:"* ]]; then
        export PATH="${PATH:+"$PATH:"}$f_path"
    fi
}

# Adding ./shell/bin to PATH (required for functions)
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
path_add "$SCRIPT_DIR/shell/bin"

ensure_homebrew() {
    if ! has brew; then
        log_info "Installing Homebrew..."
        if ! NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/null; 
        then
            log_error "Homebrew installation failed."
        fi
        log_success "Homebrew installed successfully."
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
            log_info "backup $destination"
            mkdir -p "$HOME/.cache/dotfiles"
            mv "$destination" "$dest_bak"
        else
            # if the destination is a symlink, remove the symlink
            log_info "unlink $destination"
            rm "$destination"
        fi
    fi
    parent_dir=$(dirname "$destination")
    mkdir -p "$parent_dir"
    ln -sfn "$source" "$destination"
    log_success "linked $source <-> $destination"
}

required "git"
required "curl"
required "gcc"

# Ensure homebrew is installed
ensure_homebrew

# Adding homebrew bin directory to PATH
path_add "/opt/homebrew/bin"
path_add "/home/linuxbrew/.linuxbrew/bin"
path_add "$HOME/homebrew/bin"

# Adding local "bin" directories to PATH
path_add "/usr/local/bin"
path_add "$HOME/.local/bin"
path_add "$HOME/bin"

# Install starship prompt
if  has brew && ! has starship; then
    log_info "Installing starship prompt..."
    brew install starship
    log_success "starship prompt installed successfully."
fi

# Adding both bashenv and zshenv to the home directory
link "$SCRIPT_DIR/shell/env" "$HOME/.bashenv"
link "$SCRIPT_DIR/shell/env" "$HOME/.zshenv"

# Adding both bashrc and zshrc to the home directory
link "$SCRIPT_DIR/shell/bash/.bashrc" "$HOME/.bashrc"
link "$SCRIPT_DIR/shell/zsh/.zshrc" "$HOME/.zshrc"

CONFIG_DIR="${XDG_CONFIG_HOME:-"$HOME/.config"}"

# Adding ssh configuration to $HOME/ssh
link "$SCRIPT_DIR/ssh/config" "$HOME/.ssh/config"
link "$SCRIPT_DIR/ssh/allowed_signers" "$HOME/.ssh/allowed_signers"

# Adding direnv configuration to $XDG_CONFIG_HOME/direnv/direnv.toml
link "$SCRIPT_DIR/direnv/direnv.toml" "$CONFIG_DIR/direnv/direnv.toml"
link "$SCRIPT_DIR/direnv/direnvrc" "$CONFIG_DIR/direnv/direnvrc"

# Adding git configuration to $XDG_CONFIG_HOME/git
link "$SCRIPT_DIR/git/.gitignore" "$CONFIG_DIR/git/global.gitignore"
link "$SCRIPT_DIR/git/commit-template.txt" "$CONFIG_DIR/git/commit-template.txt"

# Adding alacritty configuration to $XDG_CONFIG_HOME/alacritty
link "$SCRIPT_DIR/alacritty/alacritty.toml" "$CONFIG_DIR/alacritty/alacritty.toml"

# Adding tmux configuration to $XDG_CONFIG_HOME/tmux
link "$SCRIPT_DIR/tmux/tmux.conf" "$CONFIG_DIR/tmux/tmux.conf"