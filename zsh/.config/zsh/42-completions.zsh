# Guard against double-sourcing
[[ -n "${__ZSH_COMPLETIONS_LOADED+x}" ]] && return
__ZSH_COMPLETIONS_LOADED=1

# ~/.config/zsh/42-completions.zsh
# Zsh completion system initialization

autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
