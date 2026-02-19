#!/usr/bin/env bash
# Fetch weather using wttrbar with accurate IP-based city detection.
# ipinfo.io resolves city more accurately than wttr.in's built-in geolocation.

city=$(curl -sf --max-time 5 https://ipinfo.io/city)
location_flag=()
if [[ -n "$city" ]]; then
    location_flag=(--location "$city")
fi

wttrbar "${location_flag[@]}" \
    --main-indicator temp_C \
    --custom-indicator '{temp_C}°C {weatherDesc} {areaName}'
