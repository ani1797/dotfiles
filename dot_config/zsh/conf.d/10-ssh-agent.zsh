# 10-ssh-agent.zsh — SSH agent socket
# Linux: systemd user socket (enable: systemctl --user enable --now ssh-agent.socket)
# macOS: launchd manages the agent natively
if [[ -n "${XDG_RUNTIME_DIR:-}" && -S "${XDG_RUNTIME_DIR}/ssh-agent.socket" ]]; then
  export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
fi
