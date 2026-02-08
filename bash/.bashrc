# ~/.bashrc
# Portable bash configuration with graceful degradation

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source all config files in .config/bash/
BASH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bash"
if [[ -d "$BASH_CONFIG_DIR" ]]; then
  for config_file in "$BASH_CONFIG_DIR"/*.bash; do
    [[ -f "$config_file" ]] && source "$config_file"
  done
fi

# Source machine-specific config if it exists
[[ -f "$HOME/.bashrc.local" ]] && source "$HOME/.bashrc.local"
