#!/usr/bin/env bash
# Power menu via rofi — matches Tokyo Night theme via existing rofi config

chosen=$(printf "  Lock\n  Logout\n  Reboot\n  Shutdown" | rofi -dmenu -p "Power" -i -theme-str 'window {width: 200px;}')

case "$chosen" in
    *Lock)     hyprlock ;;
    *Logout)   hyprctl dispatch exit ;;
    *Reboot)   systemctl reboot ;;
    *Shutdown) systemctl poweroff ;;
esac
