# 15-podman.zsh — Podman Docker-compatibility setup
# Makes podman a transparent drop-in for Docker:
#   - DOCKER_HOST points to rootless podman socket
#   - docker-compose shim via podman-compose
#   - docker compose plugin via ~/.docker/cli-plugins/
#   - Shell completions
#   - Useful aliases

if ! command -v podman &>/dev/null; then
  return 0
fi

# ── Docker socket compatibility ───────────────────────────────────────────────
# Points Docker-compatible tools (VS Code Remote, testcontainers, etc.)
# to the rootless podman socket instead of /var/run/docker.sock
export DOCKER_HOST="unix://${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/podman/podman.sock"

# ── docker-compose shim ─────────────────────────────────────────────────────
# Alias docker-compose to podman-compose for scripts that call it directly
if command -v podman-compose &>/dev/null; then
  alias docker-compose='podman-compose'
fi

# docker compose plugin (e.g. 'docker compose up') — symlink on first shell load
# This is idempotent: only creates the symlink if it doesn't already exist
if command -v podman-compose &>/dev/null; then
  _dc_plugin_dir="${HOME}/.docker/cli-plugins"
  _dc_plugin="${_dc_plugin_dir}/docker-compose"
  if [[ ! -e "${_dc_plugin}" ]]; then
    mkdir -p "${_dc_plugin_dir}"
    ln -sf "$(command -v podman-compose)" "${_dc_plugin}"
  fi
  unset _dc_plugin_dir _dc_plugin
fi

# ── Aliases ───────────────────────────────────────────────────────────────────
alias pd='podman'
alias pdi='podman images'
alias pdps='podman ps'
alias pdpsa='podman ps -a'
alias pdrm='podman rm'
alias pdrmi='podman rmi'
alias pdstop='podman stop'
alias pdstart='podman start'
alias pdrun='podman run --rm -it'
alias pdexec='podman exec -it'
alias pdlogs='podman logs -f'
alias pdpull='podman pull'
alias pdbuild='podman build'
alias pdprune='podman system prune -f'

# Compose aliases
alias pdc='podman-compose'
alias pdcu='podman-compose up -d'
alias pdcd='podman-compose down'
alias pdcl='podman-compose logs -f'
alias pdcb='podman-compose build'
alias pdcr='podman-compose restart'
