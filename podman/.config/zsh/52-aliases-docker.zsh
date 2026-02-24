# Guard against double-sourcing
[[ -n "${__ZSH_ALIASES_DOCKER_LOADED+x}" ]] && return
__ZSH_ALIASES_DOCKER_LOADED=1

# ~/.config/zsh/52-aliases-docker.zsh
# Docker aliases (only if docker is installed)

# Podman fallback (alias docker to podman if docker is absent)
if command -v podman &>/dev/null && ! command -v docker &>/dev/null; then
  alias docker="podman"
fi

if command -v docker &>/dev/null || command -v podman &>/dev/null; then
  alias d="docker"
  alias dp="docker ps"
  alias dc="docker compose"
  alias dcup="docker compose up -d"
  alias dcdown="docker compose down"
  alias dclogs="docker compose logs -f"

  # Clean up unused Docker resources
  dclean() {
    echo "This will remove:"
    echo "  - All stopped containers"
    echo "  - All unused networks"
    echo "  - All dangling images"
    echo "  - All dangling build cache"
    read "?Continue? [y/N] " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      docker system prune -f
    else
      echo "Cancelled."
    fi
  }
fi
