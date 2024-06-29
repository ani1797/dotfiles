#!/usr/bin/env zsh

# set emacs keybindings
bindkey -e
set -o emacs

# Load completion system
autoload -Uz compinit && compinit
autoload -U +X bashcompinit && bashcompinit

# Setting zsh options
setopt interactive_comments # Allow comments in interactive shells
setopt prompt_subst # Allow command substitution in prompts
setopt rcquotes # Allow nested quotes in substitutions
setopt autocd # Allow cd without cd

setopt extended_glob # Enable extended globbing
setopt glob_dots # Include hidden files in globbing
setopt no_case_glob # Case insensitive globbing
setopt null_glob # Do not complain if no matches are found
setopt numeric_glob_sort # Sort filenames numerically when globbing

setopt extended_history # Enable timestamp in history
setopt hist_verify # Allow history expansion before execution
setopt hist_ignore_all_dups # Ignore duplicated commands
setopt hist_find_no_dups # Do not display duplicates when searching history
setopt hist_reduce_blanks # Remove superfluous blanks before saving history
setopt share_history # Share history across terminals
setopt inc_append_history # Immediately append to history instead of overwriting

# Loading all functions from the functions directory
if [ -d "$DOTFILES/shell/functions" ]; then
    for file in "$DOTFILES/shell/functions"/*; do
        source "$file"
    done
fi


# Loading all the custom aliases and their completions
precmd() {
    if [ -x "$DOTFILES/shell/aliases" ]; then
        source "$DOTFILES/shell/aliases"
    fi
}
precmd

# Load the plugins if they exist
if [ -x "$DOTFILES/shell/plugins" ]; then
    source "$DOTFILES/shell/plugins"
fi

