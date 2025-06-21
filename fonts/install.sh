#!/usr/bin/env bash

set -e

# Function to log messages
log_info() {
  echo "[INFO] $1"
}

# Function to check if a command exists
has() {
  command -v "$1" >/dev/null 2>&1
}

# Function to determine OS and set font directory
setup_environment() {
  OS="$(uname -s)"

  if [[ "$OS" == "Linux" ]]; then
    FONT_DIR="$HOME/.local/share/fonts/"
  elif [[ "$OS" == "Darwin" ]]; then
    FONT_DIR="$HOME/Library/Fonts/"
  else
    echo "Unsupported OS: $OS"
    exit 1
  fi

  mkdir -pv "$FONT_DIR"
}

# Function to install Fira Code fonts
install_firacode_fonts() {
  VERSION=6.2
  DOWNLOAD_URL="https://github.com/tonsky/FiraCode/releases/download/${VERSION}/Fira_Code_v${VERSION}.zip"
  TMP_DIR=$(mktemp -d)

  log_info "Downloading Fira Code v${VERSION}..."
  curl -L -o "${TMP_DIR}/Fira_Code_v${VERSION}.zip" "${DOWNLOAD_URL}"

  log_info "Unzipping..."
  unzip -q "${TMP_DIR}/Fira_Code_v${VERSION}.zip" -d "${TMP_DIR}"

  log_info "Installing Fira Code fonts..."
  find "${TMP_DIR}" -name "*.ttf" -exec cp -v {} "$FONT_DIR" \;

  log_info "Cleaning up Fira Code temporary files..."
  rm -rf "${TMP_DIR}"
}

# Function to install Nerd Fonts
install_nerd_fonts() {
  TMP_DIR=$(mktemp -d)

  log_info "Downloading Nerd Fonts..."
  git clone --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts.git "${TMP_DIR}/nerd-fonts"
  (cd "${TMP_DIR}/nerd-fonts" && git sparse-checkout set "patched-fonts")

  log_info "Installing Nerd Fonts..."
  find "${TMP_DIR}/nerd-fonts/patched-fonts" -name "*.ttf" -exec cp -v {} "$FONT_DIR" \;

  log_info "Cleaning up Nerd Fonts temporary files..."
  rm -rf "${TMP_DIR}"
}

# Function to update font cache
update_font_cache() {
  log_info "Updating font cache..."
  if [[ "$OS" == "Linux" ]]; then
    if has fc-cache; then
      fc-cache -fv
    else
      log_info "fc-cache not found. You may need to update your font cache manually."
    fi
  elif [[ "$OS" == "Darwin" ]]; then
    log_info "Font cache update not required on macOS."
  fi
}

# Main function
main() {
  setup_environment
  install_firacode_fonts
  install_nerd_fonts
  update_font_cache
  log_info "Font installation complete."
}

# Execute main function
main