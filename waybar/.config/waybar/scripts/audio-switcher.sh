#!/usr/bin/env bash
# Multi-device audio switcher for both sinks (outputs) and sources (inputs)

set -euo pipefail

# Parse wpctl status to extract devices between section headers
get_devices() {
    local device_type="$1"  # "Sinks" or "Sources"
    local next_section="$2" # Next section marker to stop parsing

    # First extract only the Audio section, then find devices
    wpctl status | awk '/^Audio$/,/^Video$|^Settings$/' | \
        awk -v start="$device_type:" -v end="$next_section:" '
            $0 ~ start {flag=1; next}
            $0 ~ end {flag=0}
            flag && /[0-9]+\./ {print}
        '
}

# Parse device line to extract ID, name, default status, and volume
parse_device() {
    local line="$1"
    # Remove box drawing characters and extract ID
    local id=$(echo "$line" | sed -E 's/^[^0-9]*([0-9]+)\..*/\1/')

    # Extract name - handle both devices with and without volume info
    local name
    if [[ "$line" =~ \[(vol:|MUTED) ]]; then
        name=$(echo "$line" | sed -E 's/^[^0-9]*[0-9]+\.\s*(.+?)\s+\[(vol:|MUTED).*/\1/' | xargs)
    else
        # Device without volume info - take everything after the ID and dot
        name=$(echo "$line" | sed -E 's/^[^0-9]*[0-9]+\.\s*(.+?)\s*$/\1/' | xargs)
    fi

    # Check for asterisk (default device)
    local is_default=false
    [[ "$line" =~ \* ]] && is_default=true

    # Extract volume or detect mute
    local volume_str="---"
    if [[ "$line" =~ \[vol:\ ([0-9.]+)\] ]]; then
        local vol="${BASH_REMATCH[1]}"
        volume_str=$(awk -v vol="$vol" 'BEGIN {printf "%.0f%%", vol * 100}')
    elif [[ "$line" =~ MUTED ]]; then
        volume_str="MUTED"
    fi

    echo "$id|$name|$is_default|$volume_str"
}

# Format device list for Rofi with section headers
format_for_rofi() {
    local rofi_list=""

    # Output devices (sinks)
    rofi_list+="━━━ Output Devices ━━━\n"
    local sinks=$(get_devices "Sinks" "Sources")
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local parsed=$(parse_device "$line")
        IFS='|' read -r id name is_default volume <<< "$parsed"
        local indicator="   "
        [[ "$is_default" == "true" ]] && indicator=" ● "
        rofi_list+="SINK|${id}|${indicator}${name}|${volume}\n"
    done <<< "$sinks"

    # Input devices (sources)
    rofi_list+="\n━━━ Input Devices ━━━\n"
    local sources=$(get_devices "Sources" "Sink inputs")
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local parsed=$(parse_device "$line")
        IFS='|' read -r id name is_default volume <<< "$parsed"
        local indicator="   "
        [[ "$is_default" == "true" ]] && indicator=" ● "
        rofi_list+="SOURCE|${id}|${indicator}${name}|${volume}\n"
    done <<< "$sources"

    echo -e "$rofi_list"
}

# Main logic
main() {
    # Check PipeWire connectivity
    if ! wpctl status &>/dev/null; then
        rofi -e "Error: Cannot connect to PipeWire"
        exit 1
    fi

    # Get formatted device list
    local device_data=$(format_for_rofi)

    # Show Rofi menu (filter out metadata lines for display)
    local chosen=$(echo -e "$device_data" | \
        awk -F'|' '{if (NF == 4) printf "%-40s [%s]\n", $3, $4; else print}' | \
        rofi -dmenu -p "Audio Device" -i \
            -theme-str 'window {width: 600px;}' \
            -theme-str 'listview {lines: 10;}')

    [[ -z "$chosen" ]] && exit 0

    # Skip if header was selected
    [[ "$chosen" =~ ^━━━ ]] && exit 0

    # Extract device name from chosen line (remove indicator and volume)
    local device_name=$(echo "$chosen" | sed -E 's/^\s*[●\s]*(.+?)\s+\[.*\]/\1/' | xargs)

    # Find the device in our data by matching name
    local device_info=$(echo -e "$device_data" | grep -F "$device_name" | head -n1)
    IFS='|' read -r device_type device_id _ _ <<< "$device_info"

    if [[ -n "$device_id" ]]; then
        # Set as default
        if wpctl set-default "$device_id" 2>/dev/null; then
            # Determine device type label
            local type_label="Output"
            [[ "$device_type" == "SOURCE" ]] && type_label="Input"

            # Send notification
            notify-send -u normal -i audio-card \
                "Audio ${type_label} Switched" \
                "$device_name"
        else
            rofi -e "Error: Failed to switch audio device"
            exit 1
        fi
    fi
}

main
