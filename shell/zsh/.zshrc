#!/usr/bin/env zsh

# Loading all the custom aliases and their completions
if [ -x "$DOTFILES/shell/aliases" ]; then
    . "$DOTFILES/shell/aliases"
fi

# Load the plugins if they exist
if [ -x "$DOTFILES/shell/plugins" ]; then
    source "$DOTFILES/shell/plugins"
fi