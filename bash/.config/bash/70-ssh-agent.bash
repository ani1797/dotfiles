# ~/.config/bash/70-ssh-agent.bash
# SSH agent auto-start

# Skip if running under 1Password SSH agent or already have an agent
if [[ -n "$SSH_AUTH_SOCK" ]]; then
  return 0 2>/dev/null || true
fi

# SSH agent socket location
SSH_AGENT_ENV="$HOME/.ssh/agent.env"

# Check if agent is running
ssh_agent_running() {
  [[ -n "$SSH_AGENT_PID" ]] && kill -0 "$SSH_AGENT_PID" 2>/dev/null
}

# Load existing agent environment
if [[ -f "$SSH_AGENT_ENV" ]]; then
  source "$SSH_AGENT_ENV" >/dev/null
fi

# Start agent if not running
if ! ssh_agent_running; then
  ssh-agent > "$SSH_AGENT_ENV" 2>/dev/null
  source "$SSH_AGENT_ENV" >/dev/null
  chmod 600 "$SSH_AGENT_ENV"

  # Add default key if it exists
  if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
    ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null
  elif [[ -f "$HOME/.ssh/id_rsa" ]]; then
    ssh-add "$HOME/.ssh/id_rsa" 2>/dev/null
  fi
fi
