# ~/.config/zsh/40-fzf.zsh
# FZF integration — keybindings and completion

command -v fzf &>/dev/null || return 0

# Source from system/user files (works on all fzf versions)
if [[ -f "/usr/share/fzf/key-bindings.zsh" ]]; then
  source /usr/share/fzf/key-bindings.zsh
  [[ -f "/usr/share/fzf/completion.zsh" ]] && source /usr/share/fzf/completion.zsh
elif [[ -f "$HOME/.fzf.zsh" ]]; then
  source "$HOME/.fzf.zsh"
fi
