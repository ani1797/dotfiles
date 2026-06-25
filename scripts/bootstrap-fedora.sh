#!/usr/bin/env bash
# bootstrap-fedora.sh — install packages on Fedora / Fedora Silverblue

set -euo pipefail
source "$(dirname "$0")/lib.sh"

DESKTOP="${DOTFILES_DESKTOP:-false}"

# ── Detect immutable variant (Silverblue / Kinoite) ──────────────────────────
if [[ -f /run/ostree-booted ]]; then
  IMMUTABLE=true
  pkg_install() { rpm-ostree install --idempotent --allow-inactive "$@"; }
  info "Detected immutable Fedora — using rpm-ostree."
else
  IMMUTABLE=false
  pkg_install() { sudo dnf install -y "$@"; }
fi

# ── Add GitHub CLI repo if missing ────────────────────────────────────────────
if ! rpm -q gh &>/dev/null; then
  info "Adding GitHub CLI repository…"
  sudo dnf config-manager addrepo \
    --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo 2>/dev/null \
    || sudo dnf config-manager --add-repo \
      https://cli.github.com/packages/rpm/gh-cli.repo 2>/dev/null \
    || warn "Could not add GitHub CLI repo — install gh manually."
fi

# ── Headless (core CLI tools) ─────────────────────────────────────────────────
HEADLESS_PKGS=(
  zsh neovim tmux git curl unzip
  direnv bat fzf gh
  zsh-autosuggestions zsh-syntax-highlighting
)

info "Installing headless packages…"
pkg_install "${HEADLESS_PKGS[@]}"

# Modern CLI tools — may not be available in older Fedora releases
OPTIONAL_PKGS=(git-delta zoxide eza starship chezmoi)
info "Installing optional CLI tools…"
pkg_install "${OPTIONAL_PKGS[@]}" 2>/dev/null \
  || warn "Some optional packages not in repos — they will be installed via fallback scripts."

# ── Desktop (Hyprland + supporting tools) ─────────────────────────────────────
if [[ "${DESKTOP}" == "true" ]]; then
  DESKTOP_PKGS=(
    hyprland hyprlock hypridle hyprpaper xdg-desktop-portal-hyprland
    kitty mako wofi
    grim slurp swappy
    brightnessctl wl-clipboard cliphist
    network-manager-applet blueman
    polkit-gnome
    jetbrains-mono-fonts-all
  )

  info "Installing desktop packages…"
  pkg_install "${DESKTOP_PKGS[@]}"
fi

if [[ "${IMMUTABLE}" == "true" ]]; then
  warn "Silverblue: a reboot may be required for layered packages to take effect."
fi

success "Fedora bootstrap complete."
