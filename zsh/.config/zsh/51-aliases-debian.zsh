# Guard against double-sourcing
[[ -n "${__ZSH_ALIASES_DEBIAN_LOADED+x}" ]] && return
__ZSH_ALIASES_DEBIAN_LOADED=1

# ~/.config/zsh/51-aliases-debian.zsh
# Debian / Ubuntu specific aliases

# Only load on Debian-based systems
if [[ -f /etc/debian_version ]]; then

  # Package management
  alias update="sudo apt update && sudo apt upgrade"
  alias install="sudo apt install"
  alias remove="sudo apt remove"
  alias search="apt search"
  alias autoremove="sudo apt autoremove"
  alias purge="sudo apt purge"
  alias aptclean="sudo apt clean && sudo apt autoclean"

  # Safer cleanup function with confirmation
  cleanup() {
    echo "Packages that can be auto-removed:"
    apt --dry-run autoremove 2>/dev/null
    read "?Remove these packages? [y/N] " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      sudo apt autoremove
    else
      echo "Cancelled."
    fi
  }

  # System information
  alias sysinfo="inxi -Fxz 2>/dev/null || lsb_release -a"
  alias services="systemctl list-units --type=service"
  alias logs="journalctl -xe"

  # Snap aliases (if snapd installed)
  if command -v snap &>/dev/null; then
    alias snapup="sudo snap refresh"
    alias snapin="sudo snap install"
    alias snaprm="sudo snap remove"
    alias snapls="snap list"
  fi

fi
