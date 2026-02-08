#!/usr/bin/env bash

# install.sh
# This script reads the configuration from config.yaml and uses GNU Stow
# to deploy dotfiles to the specified host directories.

set -euo pipefail

# Function to log messages
log() {
    echo -e "[install.sh] $*"
}

# Check required tools
for cmd in stow yq; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log "Error: required command '$cmd' not found. Please install it."
        exit 1
    fi
done

# Load configuration
CONFIG_FILE="config.yaml"
if [[ ! -f "$CONFIG_FILE" ]]; then
    log "Error: $CONFIG_FILE not found."
    exit 1
fi

# Get the current hostname
CURRENT_HOST=$(hostname)
log "Current host: $CURRENT_HOST"

# Parse modules
MODULES=$(yq -r '.modules[].name' "$CONFIG_FILE")

# Iterate over modules
while read -r module; do
    log "Processing module: $module"
    # Get module path
    MODULE_PATH=$(yq -r ".modules[] | select(.name == \"$module\") | .path" "$CONFIG_FILE")
    if [[ -z "$MODULE_PATH" ]]; then
        log "Warning: No path specified for module $module. Skipping."
        continue
    fi
    # Resolve absolute path
    MODULE_ABS="$(realpath "$MODULE_PATH")"
    if [[ ! -d "$MODULE_ABS" ]]; then
        log "Error: module directory $MODULE_ABS does not exist."
        exit 1
    fi
    # Get module-level default target (if specified)
    MODULE_TARGET=$(yq -r ".modules[] | select(.name == \"$module\") | .target // \"\"" "$CONFIG_FILE")

    # Find the matching host entry for this machine
    HOST_COUNT=$(yq -r ".modules[] | select(.name == \"$module\") | .hosts | length" "$CONFIG_FILE")
    MATCHED=false
    TARGET=""

    for i in $(seq 0 $((HOST_COUNT - 1))); do
        HOST_TYPE=$(yq -r ".modules[] | select(.name == \"$module\") | .hosts[$i] | type" "$CONFIG_FILE")

        if [[ "$HOST_TYPE" == "string" ]]; then
            HOST_NAME=$(yq -r ".modules[] | select(.name == \"$module\") | .hosts[$i]" "$CONFIG_FILE")
            if [[ "$HOST_NAME" == "$CURRENT_HOST" ]]; then
                TARGET="${MODULE_TARGET:-$HOME}"
                MATCHED=true
                break
            fi
        else
            HOST_NAME=$(yq -r ".modules[] | select(.name == \"$module\") | .hosts[$i].name" "$CONFIG_FILE")
            if [[ "$HOST_NAME" == "$CURRENT_HOST" ]]; then
                HOST_TARGET=$(yq -r ".modules[] | select(.name == \"$module\") | .hosts[$i].target // \"\"" "$CONFIG_FILE")
                TARGET="${HOST_TARGET:-${MODULE_TARGET:-$HOME}}"
                MATCHED=true
                break
            fi
        fi
    done

    if [[ "$MATCHED" != "true" ]]; then
        log "Skipping $module (not configured for host '$CURRENT_HOST')"
        continue
    fi

    # Expand environment variables in target
    TARGET=$(eval echo "$TARGET")

    log "Stowing $module for host '$CURRENT_HOST' to target: $TARGET"

    # Ensure target exists
    mkdir -p "$TARGET"

    # Run stow in module directory, specifying target
    # Use --no-folding to prevent directory-level symlinks when multiple modules share directories
    (cd "$MODULE_ABS" && stow --no-folding -t "$TARGET" --dir . .)

done <<< "$MODULES"

log "Installation complete."
