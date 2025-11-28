# Rofi Powermenu Script

entries=(
    " Lock"
    " Logout"
    " Reboot"
    " Shutdown"
    " Suspend"
)

selected=$(
    printf '%s\n' "${entries[@]}" | rofi -dmenu \
        -theme "~/.config/rofi/themes/soma.rasi" \
        -p "" \
        -width 20 \
        -lines 5 \
        -location 4 \
        -hide-scrollbar true
)

case "$selected" in
    " Lock") exec hyprlock ;;
    " Logout") hyprctl dispatch exit ;;
    " Reboot") systemctl reboot ;;
    " Shutdown") systemctl poweroff ;;
    " Suspend") systemctl suspend ;;
    *) exit 0 ;;
esac

