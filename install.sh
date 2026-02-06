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

# Parse modules
MODULES=$(yq e '.modules[] | select(.name != null) | .name' "$CONFIG_FILE")

# Iterate over modules
while read -r module; do
    log "Processing module: $module"
    # Get module path
    MODULE_PATH=$(yq e ".modules[] | select(.name == \"$module\") | .path" "$CONFIG_FILE")
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
    MODULE_TARGET=$(yq e ".modules[] | select(.name == \"$module\") | .target // \"\"" "$CONFIG_FILE")

    # Get number of hosts
    HOST_COUNT=$(yq e ".modules[] | select(.name == \"$module\") | .hosts | length" "$CONFIG_FILE")

    # For each host, use stow to deploy
    for i in $(seq 0 $((HOST_COUNT - 1))); do
        # Check if host is a string or object
        HOST_TYPE=$(yq e ".modules[] | select(.name == \"$module\") | .hosts[$i] | type" "$CONFIG_FILE")

        if [[ "$HOST_TYPE" == "!!str" ]]; then
            # Simple string host
            HOST_NAME=$(yq e ".modules[] | select(.name == \"$module\") | .hosts[$i]" "$CONFIG_FILE")
            TARGET="${MODULE_TARGET:-$HOME}"
        else
            # Object with name and possibly target
            HOST_NAME=$(yq e ".modules[] | select(.name == \"$module\") | .hosts[$i].name" "$CONFIG_FILE")
            HOST_TARGET=$(yq e ".modules[] | select(.name == \"$module\") | .hosts[$i].target // \"\"" "$CONFIG_FILE")
            # Priority: host-level target > module-level target > $HOME
            TARGET="${HOST_TARGET:-${MODULE_TARGET:-$HOME}}"
        fi

        # Expand environment variables in target
        TARGET=$(eval echo "$TARGET")

        log "Stowing $module for host '$HOST_NAME' to target: $TARGET"

        # Ensure target exists
        mkdir -p "$TARGET"

        # Run stow in module directory, specifying target
        (cd "$MODULE_ABS" && stow -t "$TARGET" --dir . .)
    done

done <<< "$MODULES"

log "Installation complete."
