# direnv stdlib extension: Podman / Docker environment helpers
#
# Usage in .envrc:
#   use podman                        # export DOCKER_HOST to rootless podman socket
#   use podman_compose                # set COMPOSE_PROJECT_NAME to current dir name
#   use podman_compose my-project     # set a custom compose project name
#   use podman_registry ghcr.io       # set a default registry prefix for this project
#
# All functions are no-ops when `podman` is not on PATH.

# Set DOCKER_HOST to the rootless podman socket.
# Makes Docker-compatible tools (VS Code, testcontainers, compose, etc.) work
# without root or a Docker daemon.
use_podman() {
  if ! has podman; then
    log_status "podman not on PATH — skipping use_podman"
    return 0
  fi

  local socket="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/podman/podman.sock"
  export DOCKER_HOST="unix://${socket}"
  export PODMAN_SOCKET="${socket}"
  log_status "Podman: DOCKER_HOST=unix://${socket}"
}

# Set compose project name so containers from different projects don't collide.
# Also sets DOCKER_HOST to the podman socket.
use_podman_compose() {
  use_podman
  local project="${1:-$(basename "${PWD}")}"
  export COMPOSE_PROJECT_NAME="${project}"
  log_status "Podman Compose: project=${COMPOSE_PROJECT_NAME}"
  watch_file docker-compose.yml docker-compose.yaml compose.yml compose.yaml .env
}

# Set a default registry prefix for image pulls in this project.
# Example: use_podman_registry ghcr.io/myorg
# Then: podman pull myimage  ->  ghcr.io/myorg/myimage
use_podman_registry() {
  local registry="${1:?use_podman_registry requires a registry argument}"
  export REGISTRY="${registry}"
  export CONTAINER_REGISTRY="${registry}"
  log_status "Podman registry: ${registry}"
}
