# ~/.config/bash/50-aliases-universal.bash
# Universal aliases that work on all systems

# Basic shortcuts
alias c="clear"
alias please="sudo"

# Parallel build (fallback to 4 cores if nproc unavailable)
alias make="make -j\$(nproc 2>/dev/null || echo 4)"
alias ninja="ninja -j\$(nproc 2>/dev/null || echo 4)"
alias n="ninja"

# Safe ls aliases (if GNU coreutils available)
if ls --color=auto &>/dev/null 2>&1; then
  alias ls="ls --color=auto"
  alias ll="ls -lh"
  alias la="ls -lha"
  alias l="ls -CF"
fi

# Grep with color
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

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
