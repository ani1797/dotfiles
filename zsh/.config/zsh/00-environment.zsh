# Guard against double-sourcing
[[ -n "${__ZSH_ENV_LOADED+x}" ]] && return
__ZSH_ENV_LOADED=1

# ~/.config/zsh/00-environment.zsh
# Basic environment setup - always runs

# Add user binary directories to PATH
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Set default editor (prefer nvim, fallback to vim)
if command -v nvim &>/dev/null; then
  export EDITOR="${EDITOR:-nvim}"
  export VISUAL="${VISUAL:-nvim}"
else
  export EDITOR="${EDITOR:-vim}"
  export VISUAL="${VISUAL:-vim}"
fi

# XDG Base Directory specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
