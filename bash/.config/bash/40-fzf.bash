# ~/.config/bash/40-fzf.bash
# FZF integration — keybindings and completion

command -v fzf &>/dev/null || return 0

# FZF provides native bash integration since v0.48+
if fzf --bash &>/dev/null; then
  eval "$(fzf --bash)"
elif [[ -f "/usr/share/fzf/key-bindings.bash" ]]; then
  source /usr/share/fzf/key-bindings.bash
  [[ -f "/usr/share/fzf/completion.bash" ]] && source /usr/share/fzf/completion.bash
elif [[ -f "$HOME/.fzf.bash" ]]; then
  source "$HOME/.fzf.bash"
fi
