#!/usr/bin/env bash
# bootstrap-debian.sh — install packages on Debian / Ubuntu (and derivatives)

set -euo pipefail
source "$(dirname "$0")/lib.sh"

DESKTOP="${DOTFILES_DESKTOP:-false}"

info "Updating package lists…"
sudo apt-get update -qq

# ── Add GitHub CLI repo if missing ────────────────────────────────────────────
if ! command -v gh &>/dev/null; then
  info "Adding GitHub CLI repository…"
  sudo apt-get install -y -qq curl gpg
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli-stable.list >/dev/null
  sudo apt-get update -qq
fi

# ── Headless (core CLI tools) ─────────────────────────────────────────────────
HEADLESS_PKGS=(
  zsh neovim tmux git curl unzip
  direnv bat fzf gh
  zsh-autosuggestions zsh-syntax-highlighting
)

info "Installing headless packages…"
sudo apt-get install -y -qq "${HEADLESS_PKGS[@]}"

# Tools not in default Debian/Ubuntu repos are handled by bootstrap-tools.sh:
#   starship, git-delta, zoxide, eza
info "Note: starship, delta, zoxide, eza will be installed via bootstrap-tools.sh."

# ── Desktop ───────────────────────────────────────────────────────────────────
if [[ "${DESKTOP}" == "true" ]]; then
  warn "Desktop packages (Hyprland, Kitty, etc.) are not in default Debian/Ubuntu repos."
  warn "Install them from source or distro-specific PPAs."
fi

success "Debian bootstrap complete."
