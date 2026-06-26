#!/usr/bin/env bash
# install.sh — bootstrap chezmoi and apply dotfiles
#
# Compatible with:
#   - GitHub Codespaces (postCreateCommand or dotfiles feature)
#   - macOS (Homebrew)
#   - Arch Linux, Fedora, Debian/Ubuntu, and derivatives
#   - Any machine with bash and curl
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

# ── Apply dotfiles via chezmoi ───────────────────────────────────────────────
# chezmoi run_onchange_before_* scripts handle all package installation
# automatically — no separate bootstrap step needed.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "${SCRIPT_DIR}/.chezmoi.toml.tmpl" ]]; then
  info "Applying dotfiles from local source…"
  chezmoi init --source "${SCRIPT_DIR}" --apply
else
  info "Initialising dotfiles from ${DOTFILES_REPO}…"
  chezmoi init "${DOTFILES_REPO}" --apply
fi

success "Dotfiles applied."

# ── Post-setup ────────────────────────────────────────────────────────────────
# Change default shell to zsh (skip in Codespaces and on macOS where zsh is default)
if command -v zsh &>/dev/null \
    && [[ "$(basename "${SHELL}")" != "zsh" ]] \
    && [[ -z "${CODESPACES:-}" ]]; then
  info "Changing default shell to zsh…"
  chsh -s "$(which zsh)" || warn "Could not change shell. Run: chsh -s \$(which zsh)"
fi

echo ""
success "Done! Open a new shell or run: exec zsh"
