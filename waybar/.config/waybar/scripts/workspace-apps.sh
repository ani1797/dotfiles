#!/usr/bin/env bash
# Shows applications in the current workspace for waybar

# Get current workspace
current_ws=$(hyprctl activeworkspace -j | jq -r '.id')

# Get windows in current workspace and format for display
windows=$(hyprctl clients -j | jq -r --arg ws "$current_ws" '
  [.[] | select(.workspace.id == ($ws | tonumber)) |
  {
    title: .title,
    class: .class,
    address: .address
  }] |
  if length == 0 then
    ""
  else
    map(.class) | join(" • ")
  end
')

# Output for waybar
if [ -z "$windows" ]; then
  echo '{"text": "", "tooltip": "No applications"}'
else
  # Truncate if too long
  if [ ${#windows} -gt 50 ]; then
    windows="${windows:0:47}..."
  fi
  echo "{\"text\": \"$windows\", \"tooltip\": \"$windows\"}"
fi
