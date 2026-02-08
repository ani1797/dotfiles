# ~/.config/zsh/30-starship.zsh
# Starship prompt initialization

if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi
