# ~/.config/bash/51-aliases-arch.bash
# Arch Linux / CachyOS specific aliases

# Only load on Arch-based systems
if [[ -f /etc/arch-release ]] || [[ -f /etc/cachyos-release ]]; then

  # Package management
  alias update="sudo pacman -Syu"
  alias install="sudo pacman -S"
  alias remove="sudo pacman -Rsn"
  alias search="pacman -Ss"
  alias cleanpkg="sudo pacman -Scc"
  alias fixpacman="sudo rm /var/lib/pacman/db.lck"

  # Safer cleanup function with confirmation
  cleanup() {
    local orphans
    orphans=$(pacman -Qtdq 2>/dev/null)
    if [[ -n "$orphans" ]]; then
      echo "Orphaned packages:"
      echo "$orphans"
      read -rp "Remove these packages? [y/N] " response
      if [[ "$response" =~ ^[Yy]$ ]]; then
        sudo pacman -Rsn $orphans
      else
        echo "Cancelled."
      fi
    else
      echo "No orphaned packages found."
    fi
  }

  # Help for people new to Arch
  alias apt="man pacman"
  alias apt-get="man pacman"
  alias yum="man pacman"
  alias dnf="man pacman"

  # System information
  alias jctl="journalctl -p 3 -xb"
  alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

  # AUR helper aliases (if installed)
  if command -v yay &>/dev/null; then
    alias yaupdate="yay -Syu"
    alias yain="yay -S"
    alias yarem="yay -Rsn"
    alias yasearch="yay -Ss"
  elif command -v paru &>/dev/null; then
    alias parupdate="paru -Syu"
    alias parain="paru -S"
    alias pararem="paru -Rsn"
    alias parasearch="paru -Ss"
  fi

fi
