# ~/.config/fish/conf.d/70-ssh-agent.fish
# SSH agent auto-start
command -v ssh-agent &>/dev/null; or return

# Prefer 1Password SSH agent if its socket exists
if test -S "$HOME/.1password/agent.sock"
    set -gx SSH_AUTH_SOCK "$HOME/.1password/agent.sock"
    exit 0
end

# Skip if already have a working agent
if set -q SSH_AUTH_SOCK; and test -S "$SSH_AUTH_SOCK"
    exit 0
end

set -l SSH_AGENT_ENV "$HOME/.ssh/agent.env.fish"

# Load existing agent environment
if test -f "$SSH_AGENT_ENV"
    source "$SSH_AGENT_ENV" >/dev/null
end

# Check if agent is running
if set -q SSH_AGENT_PID; and kill -0 $SSH_AGENT_PID 2>/dev/null
    exit 0
end

# Start new agent
eval (ssh-agent -c) >/dev/null 2>&1

# Add default key if it exists
if test -f "$HOME/.ssh/id_ed25519"
    ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null
else if test -f "$HOME/.ssh/id_rsa"
    ssh-add "$HOME/.ssh/id_rsa" 2>/dev/null
end
