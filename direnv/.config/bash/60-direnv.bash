# Guard against double-sourcing
[[ -n "${__BASH_DIRENV_LOADED+x}" ]] && return
__BASH_DIRENV_LOADED=1

# ~/.config/bash/60-direnv.bash
# Direnv integration for automatic environment loading

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi
