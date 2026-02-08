# ~/.config/bash/60-direnv.bash
# Direnv integration for automatic environment loading

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi
