#!/usr/bin/env bash
# install.sh — apply dotfiles via chezmoi
#
# Compatible with:
#   - GitHub Codespaces (postCreateCommand or dotfiles feature)
#   - Fresh Arch Linux / Fedora Silverblue machines
#   - Any Linux with chezmoi installed
#
# Usage:
#   bash install.sh            # apply dotfiles from this repo
#   DOTFILES_REPO=https://github.com/ani1797/dotfiles bash install.sh

set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/ani1797/dotfiles}"

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
    # Codespaces runs Ubuntu — install from the official script
    curl -fsSL https://get.chezmoi.io | bash -s -- -b "${HOME}/.local/bin"
    export PATH="${HOME}/.local/bin:${PATH}"
  elif command -v brew &>/dev/null; then
    brew install chezmoi
  else
    info "No package manager detected — installing chezmoi via script…"
    curl -fsSL https://get.chezmoi.io | bash -s -- -b "${HOME}/.local/bin"
    export PATH="${HOME}/.local/bin:${PATH}"
  fi
  success "chezmoi installed."
fi

# ── Detect if running inside the cloned repo already ─────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "${SCRIPT_DIR}/.chezmoi.toml.tmpl" ]]; then
  # Running from the repo — apply from local source
  info "Applying dotfiles from local source: ${SCRIPT_DIR}"
  chezmoi init --source "${SCRIPT_DIR}" --apply
else
  # Running standalone (piped or from remote) — init from GitHub
  info "Initialising dotfiles from ${DOTFILES_REPO}…"
  chezmoi init --apply "${DOTFILES_REPO}"
fi

success "Dotfiles applied."

# ── Codespaces: install essential CLI tools ───────────────────────────────────
if [[ -n "${CODESPACES:-}" ]]; then
  info "Codespaces detected — installing essential CLI tools…"

  # Install uv (Python package manager)
  if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="${HOME}/.local/bin:${PATH}"
  fi

  # Install fnm (Node version manager)
  if ! command -v fnm &>/dev/null; then
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "${HOME}/.local/bin" --skip-shell
  fi

  # Install Bun
  if ! command -v bun &>/dev/null; then
    curl -fsSL https://bun.sh/install | bash -s -- --no-profile 2>/dev/null || true
  fi

  # Install starship
  if ! command -v starship &>/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir "${HOME}/.local/bin"
  fi

  success "Codespaces setup complete."
fi

echo ""
success "Done! Open a new shell or run: source ~/.zshrc"
