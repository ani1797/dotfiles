#!/usr/bin/env bash

required curl
required unzip


VERSION=6.2
DOWNLOAD_URL="https://github.com/tonsky/FiraCode/releases/download/${VERSION}/Fira_Code_v${VERSION}.zip"
TMP_DIR=$(mktemp -d)

log_info "Downloading Fira Code v${VERSION}..."
curl -L -o "${TMP_DIR}/Fira_Code_v${VERSION}.zip" "${DOWNLOAD_URL}"

log_info "Unzipping..."
unzip -q "${TMP_DIR}/Fira_Code_v${VERSION}.zip" -d "${TMP_DIR}"

log_info "Installing..."
mkdir -pv ~/.local/share/fonts
find "${TMP_DIR}" -name "*.ttf" -exec cp -v {} ~/.local/share/fonts \;

log_info "Cleaning up..."
rm -rf "${TMP_DIR}"

log_info "Updating font cache..."
if has fc-cache; then
  fc-cache -fv
else
  log_info "fc-cache not found. You may need to update your font cache manually."
fi