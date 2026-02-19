# ~/.config/zsh/42-completions.zsh
# Zsh completion system initialization

autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
