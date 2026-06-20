# 35-incus.zsh — Incus (containers + VMs) aliases and helpers
command -v incus &>/dev/null || return 0

# ── Core instance management ─────────────────────────────────────────────────────────
alias ixls='incus list'                        # list all instances
alias ixla='incus launch'                      # launch: ixla images:alpine/3.20 mybox
alias ixst='incus start'                       # start stopped instance
alias ixsp='incus stop'                        # stop instance
alias ixrm='incus delete --force'              # delete instance
alias ixinfo='incus info'                      # instance/daemon info
alias ixcp='incus copy'                        # clone an instance
alias ixmv='incus move'                        # rename/move instance

# ── Shell access ─────────────────────────────────────────────────────────────────────────
# ixsh <name>   — interactive shell in a container (or VM if agent available)
ixsh() { incus exec "${1:?name required}" -- bash 2>/dev/null || incus exec "${1}" -- sh; }
# ixvm <name>   — shell into a VM (via incus-agent inside VM)
ixvm() { incus exec "${1:?name required}" -- bash; }
# ixrun <name> <cmd...>  — run a command non-interactively
ixrun() { local n="${1:?name required}"; shift; incus exec "${n}" -- "$@"; }

# ── File transfers ───────────────────────────────────────────────────────────────────
# ixpush <name> <src> <dst>  — copy file from host into instance
ixpush() { incus file push "${2}" "${1}/${3}"; }
# ixpull <name> <src> <dst>  — copy file from instance to host
ixpull() { incus file pull "${1}/${2}" "${3}"; }

# ── Snapshots ────────────────────────────────────────────────────────────────────────────
# ixsnap <name> [snap-name]  — create snapshot (auto-names if omitted)
ixsnap() {
  local name="${1:?name required}"
  local snap="${2:-snap-$(date +%Y%m%d-%H%M%S)}"
  incus snapshot create "${name}" "${snap}" && echo "Snapshot: ${name}/${snap}"
}
# ixrestore <name> <snap-name>  — restore to snapshot
ixrestore() { incus snapshot restore "${1:?name required}" "${2:?snap required}"; }
# ixsnaps <name>  — list snapshots for an instance
ixsnaps() { incus snapshot list "${1:?name required}"; }

# ── Image management ───────────────────────────────────────────────────────────────────
alias iximgs='incus image list'                # cached images
alias iximgs-remote='incus image list images:' # remote image browser
alias ixclean='incus image delete $(incus image list --format csv -c f | grep -v "^$")' # remove unused

# ── Quick launchers ─────────────────────────────────────────────────────────────────────
# ix <distro> [name]  — instantly launch a named container and drop into a shell
# Distro shortcuts: alpine, arch, debian, fedora, ubuntu, opensuse
ix() {
  local distro="${1:?distro required (alpine|arch|debian|fedora|ubuntu|opensuse)}"
  local name="${2:-${distro}-$(date +%H%M%S)}"
  local image
  case "${distro}" in
    alpine)   image="images:alpine/3.20"         ;;
    arch)     image="images:archlinux/current"    ;;
    debian)   image="images:debian/12"            ;;
    fedora)   image="images:fedora/40"            ;;
    ubuntu)   image="ubuntu:24.04"                ;;
    opensuse) image="images:opensuse/15.6"        ;;
    *)        image="images:${distro}"            ;;
  esac
  echo "Launching ${name} (${image})..."
  incus launch "${image}" "${name}" && ixsh "${name}"
}

# ixvm-launch <distro> [name]  — launch a full VM (same shortcuts as ix)
ixvml() {
  local distro="${1:?distro required}"
  local name="${2:-vm-${distro}-$(date +%H%M%S)}"
  local image
  case "${distro}" in
    alpine)   image="images:alpine/3.20"         ;;
    arch)     image="images:archlinux/current"    ;;
    debian)   image="images:debian/12"            ;;
    fedora)   image="images:fedora/40"            ;;
    ubuntu)   image="ubuntu:24.04"                ;;
    opensuse) image="images:opensuse/15.6"        ;;
    *)        image="images:${distro}"            ;;
  esac
  echo "Launching VM ${name} (${image}) with vm profile..."
  incus launch "${image}" "${name}" --vm --profile vm
}

# ── Status overview ─────────────────────────────────────────────────────────────────────
ix-status() {
  echo ""
  echo "  ┌─ Incus ───────────────────────────────────────"
  echo "  │"
  echo "  │  Instances:"
  incus list --format compact 2>/dev/null | sed 's/^/  │  /'
  echo "  │"
  echo "  │  Storage pools:"
  incus storage list 2>/dev/null | sed 's/^/  │  /'
  echo "  │"
  echo "  │  Networks:"
  incus network list 2>/dev/null | sed 's/^/  │  /'
  echo "  └───────────────────────────────────────────"
  echo ""
}
