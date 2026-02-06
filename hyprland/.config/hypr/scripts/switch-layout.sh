#!/usr/bin/env bash

# Layout switching script for Hyprland
# Toggles between dwindle and master layouts

# Check dependencies
if ! command -v hyprctl &> /dev/null || ! command -v jq &> /dev/null; then
    echo "Error: hyprctl and jq are required"
    exit 1
fi

# Get current layout
CURRENT_LAYOUT=$(hyprctl getoption general:layout -j | jq -r '.str')

# Toggle to the other layout
if [ "$CURRENT_LAYOUT" = "dwindle" ]; then
    NEW_LAYOUT="master"
else
    NEW_LAYOUT="dwindle"
fi

# Apply the new layout
hyprctl keyword general:layout "$NEW_LAYOUT"

# Send notification if notify-send is available
if command -v notify-send &> /dev/null; then
    notify-send -t 2000 "Hyprland Layout" "Switched to: $NEW_LAYOUT"
fi
