#!/usr/bin/env bash

mkdir -pv "$HOME/.local/share/fonts/"

log_info "Downloading fonts..."
git clone --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts.git /tmp/nerd-fonts
(cd /tmp/nerd-fonts && git sparse-checkout set "patched-fonts")

log_info "Installing fonts..."
find /tmp/nerd-fonts/patched-fonts -name "*.ttf" -exec cp -v {} "$HOME/.local/share/fonts/" \;

log_info "Cleaning up..."
rm -rvf /tmp/nerd-fonts

log_info "Updating font cache..."
if has fc-cache; then
  fc-cache -fv
else
  log_info "fc-cache not found. You may need to update your font cache manually."
fi