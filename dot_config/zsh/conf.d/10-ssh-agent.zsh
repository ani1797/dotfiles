# 10-ssh-agent.zsh — SSH agent socket
# The ssh-agent runs as a systemd user socket (always-on).
# Enable once: systemctl --user enable --now ssh-agent.socket
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
