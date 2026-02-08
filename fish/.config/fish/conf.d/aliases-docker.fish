# ~/.config/fish/conf.d/aliases-docker.fish
# Docker aliases (only if docker is installed)

if type -q docker
    alias d='docker'
    alias dp='docker ps'
    alias dc='docker compose'
    alias dcup='docker compose up -d'
    alias dcdown='docker compose down'
    alias dclogs='docker compose logs -f'

    function dclean
        echo "This will remove:"
        echo "  - All stopped containers"
        echo "  - All unused networks"
        echo "  - All dangling images"
        echo "  - All dangling build cache"
        read -P "Continue? [y/N] " -l response
        if test "$response" = y; or test "$response" = Y
            docker system prune -f
        else
            echo "Cancelled."
        end
    end
end
