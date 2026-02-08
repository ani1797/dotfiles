# ~/.zshrc
# Portable zsh configuration with graceful degradation

# Enable Powerlevel10k instant prompt if available (disabled by default - using Starship)
# To re-enable: rename 30-powerlevel10k.zsh.disabled to 30-powerlevel10k.zsh
# and uncomment the lines below:
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# Source all config files in .config/zsh/
ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
if [[ -d "$ZSH_CONFIG_DIR" ]]; then
  for config_file in "$ZSH_CONFIG_DIR"/*.zsh(N); do
    source "$config_file"
  done
fi

# Source machine-specific config if it exists
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
