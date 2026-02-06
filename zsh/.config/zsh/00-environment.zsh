# ~/.config/zsh/00-environment.zsh
# Basic environment setup - always runs

# Add user binary directories to PATH
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Set default editor
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-vim}"

# XDG Base Directory specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
