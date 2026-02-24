# Guard against double-sourcing
[[ -n "${__ZSH_STARSHIP_LOADED+x}" ]] && return
__ZSH_STARSHIP_LOADED=1

# ~/.config/zsh/30-starship.zsh
# Starship prompt initialization

if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi
