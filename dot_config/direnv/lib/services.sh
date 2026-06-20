# direnv stdlib extension: local dev services via Podman
#
# Automatically starts a named container when you enter a project directory
# and stops it when you leave (using direnv's on_exit hook).
#
# Usage in .envrc:
#   use service postgres docker.io/postgres:16 \
#     -e POSTGRES_PASSWORD=dev \
#     -e POSTGRES_DB=myapp \
#     -p 5432:5432
#
#   use service redis docker.io/redis:7-alpine \
#     -p 6379:6379
#
#   use service mailpit docker.io/axllent/mailpit \
#     -p 1025:1025 -p 8025:8025
#
# The container name is used as the service identifier.
# A stopped container is restarted; a new container is created if none exists.
# Containers are STOPPED (not removed) on exit, preserving data volumes.
#
# Requires: podman, direnv >= 2.30 (for on_exit support)

use_service() {
  if ! has podman; then
    log_status "podman not on PATH — skipping use_service"
    return 0
  fi

  local name="${1:?use_service requires a container name as first argument}"
  local image="${2:?use_service requires an image as second argument}"
  shift 2
  local opts=("$@")

  # Ensure DOCKER_HOST is set for rootless podman
  if [[ -z "${DOCKER_HOST}" ]]; then
    export DOCKER_HOST="unix://${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/podman/podman.sock"
  fi

  if podman container exists "${name}" 2>/dev/null; then
    local running
    running=$(podman inspect "${name}" --format '{{.State.Running}}' 2>/dev/null)
    if [[ "${running}" == "true" ]]; then
      log_status "service ${name}: already running"
    else
      log_status "service ${name}: starting (${image})"
      podman start "${name}" >/dev/null 2>&1 || {
        log_error "service ${name}: podman start failed"
        return 1
      }
    fi
  else
    log_status "service ${name}: creating and starting (${image})"
    podman run -d \
      --name "${name}" \
      --label "direnv-service=1" \
      --label "direnv-project=$(basename "${PWD}")" \
      "${opts[@]}" \
      "${image}" >/dev/null 2>&1 || {
      log_error "service ${name}: podman run failed — check image name and options"
      return 1
    }
  fi

  log_status "service ${name}: ready"

  # Stop (not remove) on directory exit — preserves volumes and data
  on_exit podman stop --time 5 "${name}"
}

# Convenience: remove a service container entirely (including volumes)
# Call manually: direnv_service_rm postgres
direnv_service_rm() {
  local name="${1:?direnv_service_rm requires a container name}"
  podman rm -f "${name}" 2>/dev/null && log_status "service ${name}: removed"
}
