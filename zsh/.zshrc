# ~/.zshrc
# Portable zsh configuration with graceful degradation

# Source all config files in .config/zsh/
ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
if [[ -d "$ZSH_CONFIG_DIR" ]]; then
  for config_file in "$ZSH_CONFIG_DIR"/*.zsh(N); do
    source "$config_file"
  done
fi

# Source machine-specific config if it exists
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
