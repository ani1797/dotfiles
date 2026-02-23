# ~/.config/zsh/70-labctl.zsh
# iximiuz labctl integration

# Exit early if labctl is not installed
command -v labctl &>/dev/null || return 0

# Load shell completions (if supported)
# Suppress errors in case completions don't exist
if labctl completion zsh &>/dev/null 2>&1; then
  eval "$(labctl completion zsh 2>/dev/null)"
fi

# Convenient alias
alias lab='labctl'
