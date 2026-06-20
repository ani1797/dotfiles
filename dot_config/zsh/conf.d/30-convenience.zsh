# 30-convenience.zsh — interactive shell aliases and conveniences

# ── Directory listing ───────────────────────────────────────────────────────────
if command -v eza &>/dev/null; then
  alias ls='eza --group-directories-first'
  alias l='eza -lh --group-directories-first'
  alias la='eza -lha --group-directories-first'
  alias ll='eza -lh --group-directories-first'
  alias lt='eza --tree --level=2 --group-directories-first'
  alias lta='eza --tree --level=2 -a --group-directories-first'
else
  alias l='ls -CF'
  alias la='ls -A'
  alias ll='ls -alF'
fi

# ── Navigation ───────────────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ── bat (better cat) ─────────────────────────────────────────────────────────────
if command -v bat &>/dev/null; then
  alias b='bat'
  alias cat='bat --paging=never'
  export MANPAGER='sh -c "col -bx | bat -l man -p"'
elif command -v batcat &>/dev/null; then
  alias bat='batcat'
  alias b='batcat'
  alias cat='batcat --paging=never'
fi

# ── Editor shortcut ─────────────────────────────────────────────────────────────
alias v='nvim'
alias vi='nvim'

# ── Git shortcuts ──────────────────────────────────────────────────────────────
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gcb='git checkout -b'
alias glog='git log --oneline --graph --decorate'

# ── Misc utilities ─────────────────────────────────────────────────────────────
alias path='echo $PATH | tr ":" "\n"'   # print PATH one entry per line
alias reload='source ~/.zshrc'           # reload shell config
alias ports='ss -tlnp'                   # show listening ports
alias myip='curl -s ifconfig.me'         # external IP
