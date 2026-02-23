# ~/.config/bash/70-labctl.bash
# iximiuz labctl integration

# Exit early if labctl is not installed
command -v labctl &>/dev/null || return 0

# Load shell completions (if supported)
# Suppress errors in case completions don't exist
if labctl completion bash &>/dev/null 2>&1; then
  eval "$(labctl completion bash 2>/dev/null)"
fi

# Convenient alias
alias lab='labctl'
