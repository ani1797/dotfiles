# ~/.config/zsh/20-oh-my-zsh.zsh
# Oh-My-Zsh framework - loads if available

# Only load if Oh-My-Zsh is installed
if [[ -d "/usr/share/oh-my-zsh" ]] || [[ -d "$HOME/.oh-my-zsh" ]]; then
  # Set ZSH installation path (prefer system-wide)
  export ZSH="${ZSH:-/usr/share/oh-my-zsh}"
  [[ ! -d "$ZSH" ]] && export ZSH="$HOME/.oh-my-zsh"

  # Configuration options
  DISABLE_MAGIC_FUNCTIONS="true"
  ENABLE_CORRECTION="true"
  COMPLETION_WAITING_DOTS="true"

  # Default plugins if none set
  [[ -z "${plugins[*]}" ]] && plugins=(git fzf extract)

  # Load Oh-My-Zsh
  source "$ZSH/oh-my-zsh.sh"
fi
