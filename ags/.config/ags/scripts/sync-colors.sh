#!/usr/bin/env bash
# Propagate Material You colors to all system components

set -euo pipefail

CONFIG_DIR="${HOME}/.config"
AGS_EXPORTS="${CONFIG_DIR}/ags/styles/exports"

echo "[sync-colors] Syncing Material You colors..."

# Source color variables
if [[ -f "${AGS_EXPORTS}/material-colors.sh" ]]; then
    source "${AGS_EXPORTS}/material-colors.sh"
else
    echo "[sync-colors] ERROR: Color exports not found"
    exit 1
fi

# 1. Update Kitty terminal (live reload)
if command -v kitty &>/dev/null && [[ -S "${XDG_RUNTIME_DIR}/kitty/socket" ]]; then
    kitty @ --to "unix:${XDG_RUNTIME_DIR}/kitty/socket" set-colors --all \
        "${CONFIG_DIR}/kitty/material-colors.conf" 2>/dev/null || true
    echo "[sync-colors] ✓ Kitty terminal colors updated"
fi

# 2. Reload Hyprland (border colors)
if command -v hyprctl &>/dev/null; then
    hyprctl reload &>/dev/null || true
    echo "[sync-colors] ✓ Hyprland reloaded"
fi

# 3. Signal Neovim instances to reload colorscheme
if command -v pkill &>/dev/null; then
    pkill -SIGUSR1 nvim 2>/dev/null || true
    echo "[sync-colors] ✓ Neovim instances signaled"
fi

# 4. Notify user
if command -v notify-send &>/dev/null; then
    notify-send -u low -i preferences-color \
        "Theme Updated" \
        "Material You colors synchronized"
fi

echo "[sync-colors] Done"
