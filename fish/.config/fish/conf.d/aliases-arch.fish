# ~/.config/fish/conf.d/aliases-arch.fish
# Arch Linux / CachyOS specific aliases

if test -f /etc/arch-release; or test -f /etc/cachyos-release

    # Package management
    alias update='sudo pacman -Syu'
    alias install='sudo pacman -S'
    alias remove='sudo pacman -Rsn'
    alias search='pacman -Ss'
    alias cleanpkg='sudo pacman -Scc'
    alias fixpacman='sudo rm /var/lib/pacman/db.lck'

    # Safer cleanup function with confirmation
    function cleanup
        set orphans (pacman -Qtdq 2>/dev/null)
        if test -n "$orphans"
            echo "Orphaned packages:"
            echo $orphans
            read -P "Remove these packages? [y/N] " -l response
            if test "$response" = y; or test "$response" = Y
                sudo pacman -Rsn $orphans
            else
                echo "Cancelled."
            end
        else
            echo "No orphaned packages found."
        end
    end

    # Help for people new to Arch
    alias apt='man pacman'
    alias yum='man pacman'
    alias dnf='man pacman'

    # System information
    alias jctl='journalctl -p 3 -xb'
    alias rip='expac --timefmt=\'%Y-%m-%d %T\' \'%l\t%n %v\' | sort | tail -200 | nl'

    # AUR helper aliases (if installed)
    if command -v yay &>/dev/null
        alias yaupdate='yay -Syu'
        alias yain='yay -S'
        alias yarem='yay -Rsn'
        alias yasearch='yay -Ss'
    else if command -v paru &>/dev/null
        alias parupdate='paru -Syu'
        alias parain='paru -S'
        alias pararem='paru -Rsn'
        alias parasearch='paru -Ss'
    end

end
