# ~/.config/bash/51-aliases-debian.bash
# Debian / Ubuntu specific aliases

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
    read -rp "Remove these packages? [y/N] " response
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
