# ~/.config/fish/conf.d/70-labctl.fish
# iximiuz labctl integration

# Exit early if labctl is not installed
if not type -q labctl
    exit 0
end

# Load shell completions (if supported)
# Suppress errors in case completions don't exist
if labctl completion fish &>/dev/null 2>&1
  labctl completion fish | source
end

# Convenient alias
alias lab='labctl'
