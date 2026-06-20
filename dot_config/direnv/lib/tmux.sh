# direnv stdlib extension: tmux session management per project
#
# Exports project-aware tmux variables so your prompt/tooling knows
# which session this project belongs to, and provides helpers to
# jump into (or create) the session from within a project directory.
#
# Usage in .envrc:
#   use tmux                       # session name = current directory name
#   use tmux my-project            # session name = my-project
#   use tmux my-project editor     # session + named window
#
# After `direnv allow`, running `tmux_here` or `th` will attach to
# (or create) the project session. No automatic attach — that would
# disrupt non-interactive shells, scripts, and CI.
#
# Variables exported:
#   TMUX_PROJECT        session name
#   TMUX_PROJECT_WINDOW named window (if set)

use_tmux() {
  if ! has tmux; then
    log_status "tmux not on PATH — skipping use_tmux"
    return 0
  fi

  local session="${1:-$(basename "${PWD}")}"
  local window="${2:-}"

  export TMUX_PROJECT="${session}"
  [[ -n "${window}" ]] && export TMUX_PROJECT_WINDOW="${window}"

  if [[ -z "${TMUX}" ]]; then
    # Not inside tmux — inform user how to jump in
    log_status "tmux project: ${session} — run 'th' to attach"
  else
    # Already inside tmux — create or rename the session/window silently
    local current_session
    current_session=$(tmux display-message -p '#S' 2>/dev/null)
    if [[ "${current_session}" != "${session}" ]]; then
      # Create the target session in the background if it doesn't exist
      tmux new-session -d -s "${session}" 2>/dev/null || true
      log_status "tmux project: ${session} (current: ${current_session}) — run 'th' to switch"
    else
      log_status "tmux project: ${session} (active)"
    fi
  fi
}

# Jump into (or create) the project's tmux session.
# Designed to be added as a shell alias: alias th='tmux_here'
function tmux_here() {
  local session="${TMUX_PROJECT:-$(basename "${PWD}")}"
  if [[ -n "${TMUX}" ]]; then
    # Inside tmux: switch to the session
    tmux switch-client -t "${session}" 2>/dev/null || \
      tmux new-session -d -s "${session}" && tmux switch-client -t "${session}"
  else
    # Outside tmux: attach or create
    tmux new-session -A -s "${session}"
  fi
}
export -f tmux_here 2>/dev/null || true  # export for subshells (bash only; zsh ignores)
