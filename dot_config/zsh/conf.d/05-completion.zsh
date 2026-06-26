# 05-completion.zsh — zsh completion system bootstrap
#
# Loaded early (05 band) so all tool fragments that call compdef work.
# compinit is cached: rebuilds the dump at most once per day for fast startup.

# ── fpath: static completion dirs ────────────────────────────────────────────────
typeset -U fpath
# Homebrew completions (macOS)
if command -v brew &>/dev/null; then
  fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi
# System completions (zsh-completions, tool packages install here)
[[ -d /usr/share/zsh/site-functions ]]       && fpath=(/usr/share/zsh/site-functions $fpath)
[[ -d /usr/local/share/zsh/site-functions ]] && fpath=(/usr/local/share/zsh/site-functions $fpath)
# User-local completions (rustup, cargo write here)
[[ -d "${HOME}/.local/share/zsh/site-functions" ]] \
  && fpath=("${HOME}/.local/share/zsh/site-functions" $fpath)

# ── compinit with daily-refresh cache ────────────────────────────────────────────
autoload -Uz compinit
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${HOST}-${ZSH_VERSION}"
mkdir -p "${_zcompdump:h}" 2>/dev/null
# -C skips security check for speed; only do full init when dump is >24 h old
if [[ -n ${_zcompdump}(#qN.mh+24) ]]; then
  compinit -d "${_zcompdump}"
else
  compinit -C -d "${_zcompdump}"
fi
unset _zcompdump

# ── Completion behaviour ──────────────────────────────────────────────────────────
# Case-insensitive matching, partial-word matching, substring matching
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|=*' \
  'l:|=* r:|=*'

# Interactive menu: Tab cycles, arrow keys navigate, Enter selects
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Group completions by type (files, dirs, commands, etc.)
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}── %d ──%f'
zstyle ':completion:*:warnings'     format '%F{red}no matches: %d%f'
zstyle ':completion:*:messages'     format '%F{purple}%d%f'
zstyle ':completion:*' verbose true

# Cache completions (speeds up slow completions like git branches, npm pkgs)
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

# Kill: show process list
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# SSH/SCP/RSYNC: use known_hosts for hostname completion
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip'
zstyle ':completion:*:(ssh|scp|rsync):*' group-order hosts-host hosts-domain hosts-ipaddr
zstyle ':completion:*:ssh:*' hosts-ports true

# Don't complete the same file twice
zstyle ':completion:*:rm:*' ignore-line yes
