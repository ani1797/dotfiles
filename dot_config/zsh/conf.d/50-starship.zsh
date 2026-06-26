# 50-starship.zsh — starship prompt initialisation
command -v starship &>/dev/null || return 0
eval "$(starship init zsh)"
eval "$(starship completions zsh)"
