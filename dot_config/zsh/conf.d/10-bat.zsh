# 10-bat.zsh — bat (modern cat replacement)
(( $+commands[bat] )) || return 0

alias cat='bat --paging=never'
alias catp='bat --plain --paging=never'
export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -l man -p'"
export MANROFFOPT="-c"
