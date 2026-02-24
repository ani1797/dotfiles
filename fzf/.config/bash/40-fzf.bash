# Guard against double-sourcing
[[ -n "${__BASH_FZF_LOADED+x}" ]] && return
__BASH_FZF_LOADED=1

# ~/.config/bash/40-fzf.bash
# FZF integration — keybindings, completion, and Tokyo Night theme

command -v fzf &>/dev/null || return 0

# Tokyo Night color scheme (matching starship theme)
export FZF_DEFAULT_OPTS="
  --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
  --color=fg+:#c0caf5,bg+:#1f2335,hl+:#7dcfff
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
  --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
  --border --height=40% --layout=reverse
  --preview-window=right:60%:wrap"

# Source from system/user files (works on all fzf versions)
if [[ -f "/usr/share/fzf/key-bindings.bash" ]]; then
  source /usr/share/fzf/key-bindings.bash
  [[ -f "/usr/share/fzf/completion.bash" ]] && source /usr/share/fzf/completion.bash
elif [[ -f "$HOME/.fzf.bash" ]]; then
  source "$HOME/.fzf.bash"
fi
