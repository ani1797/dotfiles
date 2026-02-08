# ~/.config/bash/52-aliases-docker.bash
# Docker aliases (only if docker is installed)

if command -v docker &>/dev/null; then
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
    read -rp "Continue? [y/N] " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      docker system prune -f
    else
      echo "Cancelled."
    fi
  }
fi
