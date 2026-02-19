# ~/.config/zsh/40-fzf.zsh
# FZF integration — keybindings and completion

command -v fzf &>/dev/null || return 0

# FZF provides native zsh integration since v0.48+
if fzf --zsh &>/dev/null; then
  eval "$(fzf --zsh)"
elif [[ -f "/usr/share/fzf/key-bindings.zsh" ]]; then
  source /usr/share/fzf/key-bindings.zsh
  [[ -f "/usr/share/fzf/completion.zsh" ]] && source /usr/share/fzf/completion.zsh
elif [[ -f "$HOME/.fzf.zsh" ]]; then
  source "$HOME/.fzf.zsh"
fi
