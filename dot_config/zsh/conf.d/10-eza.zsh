# 10-eza.zsh — eza (modern ls replacement)
(( $+commands[eza] )) || return 0

alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first --git --time-style=relative'
alias la='eza -la --icons --group-directories-first --git --time-style=relative'
alias lt='eza --tree --icons --level=2 --group-directories-first'
alias lta='eza --tree --icons --level=2 --group-directories-first -a'
