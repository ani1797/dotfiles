# ~/.bashrc
# Basic bash configuration

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Path configuration
export PATH="$HOME/bin:$PATH"

# Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Prompt
PS1='[\u@\h \W]\$ '
