# tmux helpers
command -v tmux >/dev/null 2>&1 || return 0

alias tls='tmux ls'
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tk='tmux kill-session -t'
alias td='tmux detach'

# tat: attach to <name>, or create it if missing
tat() {
  local name="${1:-main}"
  tmux new-session -A -s "$name"
}
