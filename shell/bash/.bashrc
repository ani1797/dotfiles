#!/usr/bin/env bash
# ~/.bashrc: executed by bash(1) for non-login shells.

# Bash history controls
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=erasedups
HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"
shopt -s histappend
PROMPT_COMMAND="history -a; history -r; $PROMPT_COMMAND"
export HISTSIZE HISTFILESIZE HISTCONTROL HISTIGNORE

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

## Load the $HOME/.bashenv if executable and exists (for automatic loading BASH_ENV could be set in ~/.profile)
# shellcheck source=/dev/null
[ -x "$HOME/.bashenv" ] && source "$HOME/.bashenv"

# Load all the plugins from $DOTFILES/shell/bash/plugins
if [ -d "$DOTFILES/shell/bash/plugins" ]; then
    for file in "$DOTFILES/shell/bash/plugins"/*; do
        # shellcheck source=/dev/null
        . "$file"
    done
fi

## Enable completion for bash
### System Completions
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    # shellcheck source=/dev/null
    source /etc/bash_completion
fi
### Homebrew Completions
for i in $HOMEBREW_PREFIX/etc/bash_completion.d/*; do source $i; done
### User Completions
if [ -d "$DOTFILES/shell/bash/completions" ]; then
    for file in "$DOTFILES/shell/bash/completions"/*; do
        # shellcheck source=/dev/null
        . "$file"
    done
fi

# Loading all common aliases
[ -x "$DOTFILES/shell/aliases" ] && source "$DOTFILES/shell/aliases"

# Source OnePassword Plugins
if has op && [ -x "$HOME/.config/op/plugins.sh" ]; then
    source "$HOME/.config/op/plugins.sh"
fi

# Source ~/.env.local file if it exists
if [ -f "$HOME/.env.local" ]; then
    source "$HOME/.env.local"
fi