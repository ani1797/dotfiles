#!/usr/bin/env bash

# Window snapping script for Hyprland
# Snaps the active window to various screen positions

# Check dependencies
if ! command -v hyprctl &> /dev/null || ! command -v jq &> /dev/null; then
    echo "Error: hyprctl and jq are required"
    exit 1
fi

# Get the snap position from argument
POSITION="$1"

if [ -z "$POSITION" ]; then
    echo "Usage: $0 <position>"
    echo "Positions: left, right, top, bottom, topleft, topright, bottomleft, bottomright, center"
    exit 1
fi

# Get active monitor info
MONITOR_INFO=$(hyprctl monitors -j | jq '.[] | select(.focused == true)')
MONITOR_X=$(echo "$MONITOR_INFO" | jq '.x')
MONITOR_Y=$(echo "$MONITOR_INFO" | jq '.y')
MONITOR_WIDTH=$(echo "$MONITOR_INFO" | jq '.width')
MONITOR_HEIGHT=$(echo "$MONITOR_INFO" | jq '.height')

# Get gaps configuration
GAPS_OUT=$(hyprctl getoption general:gaps_out -j | jq '.int')
GAPS_IN=$(hyprctl getoption general:gaps_in -j | jq '.int')

# Calculate usable area (accounting for outer gaps)
USABLE_X=$((MONITOR_X + GAPS_OUT))
USABLE_Y=$((MONITOR_Y + GAPS_OUT))
USABLE_WIDTH=$((MONITOR_WIDTH - 2 * GAPS_OUT))
USABLE_HEIGHT=$((MONITOR_HEIGHT - 2 * GAPS_OUT))

# Calculate half dimensions (accounting for inner gap in the middle)
HALF_WIDTH=$((USABLE_WIDTH / 2 - GAPS_IN / 2))
HALF_HEIGHT=$((USABLE_HEIGHT / 2 - GAPS_IN / 2))

# Calculate quarter dimensions
QUARTER_WIDTH=$HALF_WIDTH
QUARTER_HEIGHT=$HALF_HEIGHT

# Determine target position and size based on argument
case "$POSITION" in
    left)
        TARGET_X=$USABLE_X
        TARGET_Y=$USABLE_Y
        TARGET_WIDTH=$HALF_WIDTH
        TARGET_HEIGHT=$USABLE_HEIGHT
        ;;
    right)
        TARGET_X=$((USABLE_X + HALF_WIDTH + GAPS_IN))
        TARGET_Y=$USABLE_Y
        TARGET_WIDTH=$HALF_WIDTH
        TARGET_HEIGHT=$USABLE_HEIGHT
        ;;
    top)
        TARGET_X=$USABLE_X
        TARGET_Y=$USABLE_Y
        TARGET_WIDTH=$USABLE_WIDTH
        TARGET_HEIGHT=$HALF_HEIGHT
        ;;
    bottom)
        TARGET_X=$USABLE_X
        TARGET_Y=$((USABLE_Y + HALF_HEIGHT + GAPS_IN))
        TARGET_WIDTH=$USABLE_WIDTH
        TARGET_HEIGHT=$HALF_HEIGHT
        ;;
    topleft)
        TARGET_X=$USABLE_X
        TARGET_Y=$USABLE_Y
        TARGET_WIDTH=$QUARTER_WIDTH
        TARGET_HEIGHT=$QUARTER_HEIGHT
        ;;
    topright)
        TARGET_X=$((USABLE_X + QUARTER_WIDTH + GAPS_IN))
        TARGET_Y=$USABLE_Y
        TARGET_WIDTH=$QUARTER_WIDTH
        TARGET_HEIGHT=$QUARTER_HEIGHT
        ;;
    bottomleft)
        TARGET_X=$USABLE_X
        TARGET_Y=$((USABLE_Y + QUARTER_HEIGHT + GAPS_IN))
        TARGET_WIDTH=$QUARTER_WIDTH
        TARGET_HEIGHT=$QUARTER_HEIGHT
        ;;
    bottomright)
        TARGET_X=$((USABLE_X + QUARTER_WIDTH + GAPS_IN))
        TARGET_Y=$((USABLE_Y + QUARTER_HEIGHT + GAPS_IN))
        TARGET_WIDTH=$QUARTER_WIDTH
        TARGET_HEIGHT=$QUARTER_HEIGHT
        ;;
    center)
        # Center a 60% width, 70% height window
        CENTER_WIDTH=$((USABLE_WIDTH * 60 / 100))
        CENTER_HEIGHT=$((USABLE_HEIGHT * 70 / 100))
        TARGET_X=$((USABLE_X + (USABLE_WIDTH - CENTER_WIDTH) / 2))
        TARGET_Y=$((USABLE_Y + (USABLE_HEIGHT - CENTER_HEIGHT) / 2))
        TARGET_WIDTH=$CENTER_WIDTH
        TARGET_HEIGHT=$CENTER_HEIGHT
        ;;
    *)
        echo "Invalid position: $POSITION"
        exit 1
        ;;
esac

# Make window floating if it isn't already
hyprctl dispatch togglefloating

# Move and resize the window
hyprctl dispatch moveactive exact $TARGET_X $TARGET_Y
hyprctl dispatch resizeactive exact $TARGET_WIDTH $TARGET_HEIGHT
