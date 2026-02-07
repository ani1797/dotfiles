# ~/.bashrc
# Basic bash configuration

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Path configuration
export PATH="$HOME/bin:$PATH"

# Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias g='git'

# Prompt
PS1='[\u@\h \W]\$ '

# Direnv integration (if available)
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi
