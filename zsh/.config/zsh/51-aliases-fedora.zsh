# ~/.config/zsh/51-aliases-fedora.zsh
# Fedora / RHEL specific aliases

# Only load on Fedora/RHEL-based systems
if [[ -f /etc/fedora-release ]] || [[ -f /etc/redhat-release ]]; then

  # Detect dnf vs yum
  if command -v dnf &>/dev/null; then
    # DNF (modern Fedora/RHEL)
    alias update="sudo dnf upgrade"
    alias install="sudo dnf install"
    alias remove="sudo dnf remove"
    alias search="dnf search"
    alias cleanpkg="sudo dnf clean all"
    alias info="dnf info"

    # Safer cleanup function
    cleanup() {
      echo "Packages that can be auto-removed:"
      dnf list autoremove 2>/dev/null
      read "?Remove these packages? [y/N] " response
      if [[ "$response" =~ ^[Yy]$ ]]; then
        sudo dnf autoremove
      else
        echo "Cancelled."
      fi
    }

  else
    # YUM (older RHEL/CentOS)
    alias update="sudo yum update"
    alias install="sudo yum install"
    alias remove="sudo yum remove"
    alias search="yum search"
    alias cleanpkg="sudo yum clean all"
    alias info="yum info"
  fi

  # System information
  alias services="systemctl list-units --type=service"
  alias logs="journalctl -xe"
  alias firewall="sudo firewall-cmd --list-all"

  # SELinux helpers
  if command -v getenforce &>/dev/null; then
    alias selinux-status="getenforce"
    alias selinux-permissive="sudo setenforce 0"
    alias selinux-enforcing="sudo setenforce 1"
  fi

fi
