#!/bin/sh
# Refresh Hyprland UI components without resetting wallpaper

SCRIPTSDIR="$HOME/.config/hypr/scripts"
WALLPAPER_EFFECTS="$HOME/.config/hypr/configs/appearance/wallpaper_effects/.wallpaper_current"

# List of processes to kill - REMOVED hyprpaper from this list
_procs=(waybar rofi swaync ags qs)

# Kill processes in parallel
for p in "${_procs[@]}"; do
    pkill -x "$p" 2>/dev/null &
done
wait

# Wait for processes to terminate with timeout
for p in "${_procs[@]}"; do
    timeout=10
    while pgrep -x "$p" >/dev/null && [ $timeout -gt 0 ]; do
        sleep 0.1
        ((timeout--))
    done
    if pgrep -x "$p" >/dev/null; then
        pkill -9 -x "$p" 2>/dev/null
    fi
done

# Run wallust to update colors
if [[ -f "$WALLPAPER_EFFECTS" ]]; then
    wallust run "$WALLPAPER_EFFECTS"
fi

# Reload hyprpaper WITHOUT killing it first
hyprpaper &
swaync-client --reload-config &

# Relaunch other services
ags &
qs &
swaync > /dev/null 2>&1 &

# Start waybar only if not running
sleep 0.5
if ! pgrep -x waybar >/dev/null; then
    waybar &
fi

# Final notifications
sleep 1
notify-send --replace-id=1 "System refreshed"
hyprctl reload &
