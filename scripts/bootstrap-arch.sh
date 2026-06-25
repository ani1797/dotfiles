#!/usr/bin/env bash
# bootstrap-arch.sh — install packages on Arch Linux (and derivatives)

set -euo pipefail
source "$(dirname "$0")/lib.sh"

DESKTOP="${DOTFILES_DESKTOP:-false}"

# ── Headless (core CLI tools) ─────────────────────────────────────────────────
HEADLESS_PKGS=(
  zsh neovim tmux git curl unzip
  chezmoi direnv starship
  git-delta zoxide eza bat fzf
  github-cli
  zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search
)

info "Installing headless packages…"
sudo pacman -S --noconfirm --needed "${HEADLESS_PKGS[@]}"

# ── paru (AUR helper) ────────────────────────────────────────────────────────
if ! command -v paru &>/dev/null; then
  info "Building paru from AUR…"
  sudo pacman -S --noconfirm --needed base-devel
  PARU_BUILD="$(mktemp -d)"
  git clone https://aur.archlinux.org/paru.git "${PARU_BUILD}"
  (cd "${PARU_BUILD}" && makepkg -si --noconfirm)
  rm -rf "${PARU_BUILD}"
  success "paru installed."
fi

# ── Desktop (Hyprland + supporting tools) ─────────────────────────────────────
if [[ "${DESKTOP}" == "true" ]]; then
  DESKTOP_PKGS=(
    hyprland hyprlock hypridle hyprpaper xdg-desktop-portal-hyprland
    kitty mako wofi
    grim slurp swappy
    brightnessctl wl-clipboard cliphist
    network-manager-applet blueman
    polkit-gnome
    ttf-jetbrains-mono-nerd
    qt6-declarative qt6-wayland
  )

  info "Installing desktop packages…"
  sudo pacman -S --noconfirm --needed "${DESKTOP_PKGS[@]}"
fi

success "Arch bootstrap complete."
