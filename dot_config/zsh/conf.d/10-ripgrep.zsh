# 10-ripgrep.zsh — ripgrep configuration
(( $+commands[rg] )) || return 0

export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/ripgrep/config"
