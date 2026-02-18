# ~/.config/zsh/50-aliases-universal.zsh
# Universal aliases that work on all systems

# Basic shortcuts
alias c="clear"
alias please="sudo"

# Modern command substitution (safer than backticks)
# Fallback to 4 cores if nproc unavailable
alias make="make -j\$(nproc 2>/dev/null || echo 4)"
alias ninja="ninja -j\$(nproc 2>/dev/null || echo 4)"
alias n="ninja"

# Directory listing (prefer eza over ls)
if command -v eza &>/dev/null; then
  alias ls="eza --icons --group-directories-first"
  alias ll="eza -l --icons --group-directories-first --git"
  alias la="eza -la --icons --group-directories-first --git"
  alias l="eza -1 --icons"
  alias lt="eza --tree --icons --level=2"
  alias lg="eza -l --icons --git --git-ignore"
elif ls --color=auto &>/dev/null 2>&1; then
  alias ls="ls --color=auto"
  alias ll="ls -lh"
  alias la="ls -lha"
  alias l="ls -CF"
fi

# Git aliases (if git installed)
if command -v git &>/dev/null; then
  alias g="git"
  alias gs="git status"
  alias gd="git diff"
  alias ga="git add"
  alias gc="git commit"
  alias gp="git push"
  alias gl="git log --oneline --graph --decorate"
fi

# Safety aliases
alias cp="cp -i"    # Prompt before overwrite
alias mv="mv -i"    # Prompt before overwrite
alias rm="rm -i"    # Prompt before delete

# Directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Process management
alias ps="ps auxf"
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"

# Network
alias ports="netstat -tulanp"
alias listening="lsof -i -P | grep LISTEN"

# Dotfiles quick access (~dot expands everywhere: cd ~dot, ls ~dot/starship)
export DOT="$HOME/.local/share/dotfiles"
hash -d dot="$HOME/.local/share/dotfiles"

# Set a temporary environment variable in the current session
set_env() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: set_env KEY VALUE" >&2; return 1
  fi
  export "$1=$2"
}
