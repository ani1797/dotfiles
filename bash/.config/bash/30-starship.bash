# ~/.config/bash/30-starship.bash
# Starship prompt initialization

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
