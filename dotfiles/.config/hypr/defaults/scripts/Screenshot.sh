#!/bin/sh

# Directory to save screenshots
DIR="$HOME/Pictures/Screenshots"

# Create directory if it doesn't exist
mkdir -p "$DIR"

# Filename with timestamp
FILENAME="$DIR/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png"

# Take screenshot
hyprshot -z -m region -o $DIR -s

# Optional: notify when saved
if command -v notify-send >/dev/null; then
    notify-send "Screenshot saved" "$FILENAME"
fi

