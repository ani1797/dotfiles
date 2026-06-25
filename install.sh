#!/usr/bin/env bash
# install.sh — bootstrap a machine with dotfiles
#
# Compatible with:
#   - GitHub Codespaces (postCreateCommand or dotfiles feature)
#   - Fresh Arch Linux / Fedora / Debian / Ubuntu machines
#   - Any Linux with chezmoi installed
#
# Usage:
#   bash install.sh                # headless setup (default)
#   bash install.sh --desktop      # include desktop packages (Hyprland, Kitty, …)
#   DOTFILES_REPO=https://github.com/ani1797/dotfiles bash install.sh

set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/ani1797/dotfiles}"
DOTFILES_DESKTOP="${DOTFILES_DESKTOP:-false}"

# ── Parse flags ───────────────────────────────────────────────────────────────
for arg in "$@"; do
  case "$arg" in
    --desktop) DOTFILES_DESKTOP=true ;;
    --help|-h)
      printf 'Usage: bash install.sh [--desktop]\n\n'
      printf 'Options:\n'
      printf '  --desktop   Include desktop packages (Hyprland, Kitty, etc.)\n'
      printf '  --help      Show this help message\n'
      exit 0 ;;
  esac
done

export DOTFILES_DESKTOP

# ── Logging ───────────────────────────────────────────────────────────────────
info()    { printf '\033[1;34m[dotfiles]\033[0m %s\n' "$*"; }
success() { printf '\033[1;32m[dotfiles]\033[0m %s\n' "$*"; }
warn()    { printf '\033[1;33m[dotfiles]\033[0m %s\n' "$*" >&2; }
die()     { printf '\033[1;31m[dotfiles]\033[0m ERROR: %s\n' "$*" >&2; exit 1; }

# ── Install chezmoi if missing ────────────────────────────────────────────────
if ! command -v chezmoi &>/dev/null; then
  info "chezmoi not found — installing…"
  if command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm --needed chezmoi
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y chezmoi
  elif command -v apt-get &>/dev/null; then
    curl -fsSL https://get.chezmoi.io | bash -s -- -b "${HOME}/.local/bin"
    export PATH="${HOME}/.local/bin:${PATH}"
  elif command -v brew &>/dev/null; then
    brew install chezmoi
  else
    curl -fsSL https://get.chezmoi.io | bash -s -- -b "${HOME}/.local/bin"
    export PATH="${HOME}/.local/bin:${PATH}"
  fi
  success "chezmoi installed."
fi

# ── Resolve source directory ─────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "${SCRIPT_DIR}/.chezmoi.toml.tmpl" ]]; then
  SOURCE_DIR="${SCRIPT_DIR}"
else
  # Running standalone (piped from curl) — let chezmoi clone the repo
  info "Initialising dotfiles from ${DOTFILES_REPO}…"
  chezmoi init "${DOTFILES_REPO}"
  SOURCE_DIR="$(chezmoi source-path)"
fi

# ── OS-specific package bootstrap ────────────────────────────────────────────
detect_os() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    case "${ID}" in
      arch|endeavouros|manjaro)    echo "arch" ;;
      fedora)                      echo "fedora" ;;
      debian|ubuntu|linuxmint|pop) echo "debian" ;;
      *)                           echo "unknown" ;;
    esac
  else
    echo "unknown"
  fi
}

OS_ID="$(detect_os)"
BOOTSTRAP="${SOURCE_DIR}/scripts/bootstrap-${OS_ID}.sh"

if [[ -f "${BOOTSTRAP}" ]]; then
  info "Running ${OS_ID} package bootstrap…"
  bash "${BOOTSTRAP}" || warn "Some packages may have failed to install."
else
  warn "No bootstrap script for OS '${OS_ID}' — skipping system packages."
fi

# ── Cross-platform developer tools ───────────────────────────────────────────
info "Installing cross-platform developer tools…"
bash "${SOURCE_DIR}/scripts/bootstrap-tools.sh" \
  || warn "Some developer tools may have failed to install."

# ── Apply dotfiles via chezmoi ───────────────────────────────────────────────
info "Applying dotfiles…"
chezmoi init --source "${SOURCE_DIR}" --apply

success "Dotfiles applied."

# ── Post-setup ────────────────────────────────────────────────────────────────
# Change default shell to zsh (skip in Codespaces)
if command -v zsh &>/dev/null \
    && [[ "$(basename "${SHELL}")" != "zsh" ]] \
    && [[ -z "${CODESPACES:-}" ]]; then
  info "Changing default shell to zsh…"
  chsh -s "$(which zsh)" || warn "Could not change shell. Run: chsh -s \$(which zsh)"
fi

# Enable ssh-agent socket on desktop installs
if [[ "${DOTFILES_DESKTOP}" == "true" ]]; then
  systemctl --user enable --now ssh-agent.socket 2>/dev/null \
    && success "ssh-agent.socket enabled." \
    || warn "Could not enable ssh-agent.socket."
fi

echo ""
success "Done! Open a new shell or run: exec zsh"
