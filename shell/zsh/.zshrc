#!/usr/bin/env zsh
# ~/.zshrc: executed by zsh(1) for interactive shells.

# History controls
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

setopt extended_history # Enable timestamp in history
setopt hist_verify # Allow history expansion before execution
setopt hist_ignore_all_dups # Ignore duplicated commands
setopt hist_find_no_dups # Do not display duplicates when searching history
setopt hist_reduce_blanks # Remove superfluous blanks before saving history
setopt share_history # Share history across terminals
setopt inc_append_history # Immediately append to history instead of overwriting
setopt append_history # Append history instead of overwriting
setopt hist_expire_dups_first # Expire duplicated commands first when trimming history

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

# Check window size after each command and update LINES and COLUMNS if necessary
autoload -Uz add-zsh-hook
function update_window_size() {
    (( LINES != $(tput lines) || COLUMNS != $(tput cols) )) && {
        LINES=$(tput lines)
        COLUMNS=$(tput cols)
    }
}
add-zsh-hook precmd update_window_size

## Load the $HOME/.zshenv if executable and exists (for automatic loading BASH_ENV could be set in ~/.profile)
# shellcheck source=/dev/null
[ -x "$HOME/.zshenv" ] && source "$HOME/.zshenv"

# Load all the plugins from $DOTFILES/shell/zsh/plugins
if [ -d "$DOTFILES/shell/zsh/plugins" ]; then
    for file in "$DOTFILES/shell/zsh/plugins"/*; do
        # shellcheck source=/dev/null
        . "$file"
    done
fi

# Enable auto completions
autoload -U +X compinit && compinit -C
autoload -U +X bashcompinit && bashcompinit

# Load all the completions from $DOTFILES/shell/zsh/completions
if [ -d "$DOTFILES/shell/zsh/completions" ]; then
    for file in "$DOTFILES/shell/zsh/completions"/*; do
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