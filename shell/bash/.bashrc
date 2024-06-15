#!/usr/bin/env bash
# ~/.bashrc: executed by bash(1) for non-login shells.

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

## Load the $HOME/.zshenv if executable and exists (for automatic loading BASH_ENV could be set in ~/.profile)
# shellcheck source=/dev/null
[ -x "$HOME/.bashenv" ] && source "$HOME/.bashenv"

# Loading all the custom aliases and their completions
if [ -x "$DOTFILES/shell/aliases" ]; then
    source "$DOTFILES/shell/aliases"
fi

## Load the Plugins installed
if [ -x "$DOTFILES/shell/plugins" ]; then
    source "$DOTFILES/shell/plugins"
fi
