# Guard against double-sourcing
[[ -n "${__BASH_FZF_LOADED+x}" ]] && return
__BASH_FZF_LOADED=1

# ~/.config/bash/40-fzf.bash
# FZF integration — keybindings and completion

command -v fzf &>/dev/null || return 0

# Source from system/user files (works on all fzf versions)
if [[ -f "/usr/share/fzf/key-bindings.bash" ]]; then
  source /usr/share/fzf/key-bindings.bash
  [[ -f "/usr/share/fzf/completion.bash" ]] && source /usr/share/fzf/completion.bash
elif [[ -f "$HOME/.fzf.bash" ]]; then
  source "$HOME/.fzf.bash"
fi
