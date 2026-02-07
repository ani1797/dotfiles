# Direnv integration for automatic environment loading
# This hook allows direnv to automatically load and unload environment
# variables based on .envrc files in the current directory.
#
# Documentation: https://direnv.net/

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
