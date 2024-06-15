#!/usr/bin/env zsh

# Loading all the custom aliases and their completions
precmd() {
    if [ -x "$DOTFILES/shell/aliases" ]; then
        . "$DOTFILES/shell/aliases"
    fi
}
precmd

# Load the plugins if they exist
if [ -x "$DOTFILES/shell/plugins" ]; then
    source "$DOTFILES/shell/plugins"
fi

