#!/usr/bin/env bash
# Propagate Material You colors to all system components

set -euo pipefail

CONFIG_DIR="${HOME}/.config"
AGS_EXPORTS="${CONFIG_DIR}/ags/styles/exports"
DEBUG="${DEBUG:-0}"

# Debug logging function
debug_log() {
    [[ "${DEBUG}" == "1" ]] && echo "[sync-colors][DEBUG] $*" >&2
}

# Validate runtime directory
: "${XDG_RUNTIME_DIR:=/run/user/$(id -u)}"
if [[ ! -d "${XDG_RUNTIME_DIR}" ]]; then
    echo "[sync-colors] WARNING: XDG_RUNTIME_DIR not available"
fi

debug_log "CONFIG_DIR=${CONFIG_DIR}"
debug_log "XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR}"

echo "[sync-colors] Syncing Material You colors..."

# Source color variables
if [[ -f "${AGS_EXPORTS}/material-colors.sh" ]]; then
    source "${AGS_EXPORTS}/material-colors.sh"
    debug_log "Sourced color exports"
else
    echo "[sync-colors] ERROR: Color exports not found"
    exit 1
fi

# 1. Update Kitty terminal (live reload)
if command -v kitty &>/dev/null; then
    KITTY_CONF="${CONFIG_DIR}/kitty/material-colors.conf"

    if [[ ! -f "${KITTY_CONF}" ]]; then
        echo "[sync-colors] WARNING: Kitty config not found at ${KITTY_CONF}"
    elif [[ -S "${XDG_RUNTIME_DIR}/kitty/socket" ]]; then
        kitty @ --to "unix:${XDG_RUNTIME_DIR}/kitty/socket" set-colors --all \
            "${KITTY_CONF}" 2>/dev/null || true
        echo "[sync-colors] ✓ Kitty terminal colors updated"
        debug_log "Applied Kitty config from ${KITTY_CONF}"
    else
        debug_log "Kitty socket not found at ${XDG_RUNTIME_DIR}/kitty/socket"
    fi
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
