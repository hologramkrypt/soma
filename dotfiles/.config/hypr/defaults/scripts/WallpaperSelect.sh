#!/bin/sh
# Wallpaper Selector - Unique Thumbnails for Same Filenames

# Configuration
WALLPAPER_DIR="$HOME/.assets/.wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper_thumbs"
SCRIPTS_DIR="$HOME/.config/hypr/defaults/scripts"
ROFI_THEME="$HOME/.config/rofi/config-wallpaper.rasi"
WALLPAPER_CURRENT="$HOME/.config/hypr/defaults/appearance/wallpaper_effects/.wallpaper_current"

# Thumbnail dimensions (matches rofi element size)
THUMB_WIDTH=220
THUMB_HEIGHT=240

# Create cache directory
mkdir -p "$CACHE_DIR"

# Kill existing wallpaper processes
kill_wallpaper_processes() {
    pkill hyprpaper 2>/dev/null
}

# Get all monitors
get_monitors() {
    hyprctl monitors -j | jq -r '.[].name'
}

# Collect wallpapers from directory
collect_wallpapers() {
    local dir="$1"
    mapfile -d '' PICS < <(find -L "$dir" -maxdepth 1 -type f \( \
        -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o \
        -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.webp" -o \
        -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.webm" \) -print0)
}

# Create unique thumbnail name based on full path
get_thumbnail_name() {
    local pic_path="$1"
    # Create a unique hash based on the full file path
    local path_hash=$(echo -n "$pic_path" | md5sum | cut -d' ' -f1)
    local name=$(basename "$pic_path")
    local thumb_name="thumb_${THUMB_WIDTH}x${THUMB_HEIGHT}_${path_hash}_${name}.png"
    echo "$CACHE_DIR/$thumb_name"
}

# Create uniform thumbnail - ZOOM TO FILL
create_thumbnail() {
    local pic_path="$1"
    local thumb_path=$(get_thumbnail_name "$pic_path")
    
    # Return existing thumbnail if available and recent
    if [[ -f "$thumb_path" ]] && [[ "$pic_path" -ot "$thumb_path" ]]; then
        echo "$thumb_path"
        return
    fi
    
    local name=$(basename "$pic_path")
    echo "Creating uniform thumbnail for: $name (from: $pic_path)" >&2
    
    # Create uniform thumbnail that fills the space
    if [[ "$name" =~ \.(mp4|mkv|mov|webm)$ ]]; then
        # Video thumbnail - extract frame and resize uniformly
        ffmpeg -v error -y -i "$pic_path" -ss 00:00:01 -vframes 1 \
            -vf "scale=${THUMB_WIDTH}:${THUMB_HEIGHT}:force_original_aspect_ratio=cover:flags=lanczos" \
            "$thumb_path" 2>/dev/null
    elif [[ "$name" =~ \.gif$ ]]; then
        # GIF thumbnail - use first frame
        magick "$pic_path[0]" \
            -resize "${THUMB_WIDTH}x${THUMB_HEIGHT}^" \
            -gravity center \
            -extent "${THUMB_WIDTH}x${THUMB_HEIGHT}" \
            -quality 90 \
            "$thumb_path" 2>/dev/null
    else
        # Image thumbnail - resize to fill space uniformly
        if command -v magick >/dev/null 2>&1; then
            magick "$pic_path" \
                -resize "${THUMB_WIDTH}x${THUMB_HEIGHT}^" \
                -gravity center \
                -extent "${THUMB_WIDTH}x${THUMB_HEIGHT}" \
                -quality 90 \
                "$thumb_path" 2>/dev/null
        elif command -v convert >/dev/null 2>&1; then
            convert "$pic_path" \
                -resize "${THUMB_WIDTH}x${THUMB_HEIGHT}^" \
                -gravity center \
                -extent "${THUMB_WIDTH}x${THUMB_HEIGHT}" \
                -quality 90 \
                "$thumb_path" 2>/dev/null
        else
            echo "image-x-generic"
            return
        fi
    fi
    
    if [[ -f "$thumb_path" ]]; then
        echo "$thumb_path"
    else
        echo "image-x-generic"
    fi
}

# Generate menu content with folder context
generate_menu() {
    local dir="$1"
    
    # Add back button if not in root
    [[ "$dir" != "$WALLPAPER_DIR" ]] && printf "%s\x00icon\x1f%s\n" ".. (back)" "go-previous"

    # Add folders
    while IFS= read -r -d '' d; do
        folder_name="$(basename "$d")"
        printf "%s/\x00icon\x1ffolder\n" "$folder_name"
    done < <(find "$dir" -maxdepth 1 -type d -not -path "$dir" -print0 | sort -z)

    # Add wallpapers
    collect_wallpapers "$dir"
    [[ ${#PICS[@]} -gt 0 ]] || return

    # Add random option
    printf "%s\x00icon\x1f%s\n" ". random" "media-playlist-shuffle"

    # Add wallpapers with unique thumbnails
    for pic_path in "${PICS[@]}"; do
        name=$(basename "$pic_path")
        thumb=$(create_thumbnail "$pic_path")
        
        if [[ -f "$thumb" ]]; then
            printf "%s\x00icon\x1f%s\n" "$name" "$thumb"
        else
            printf "%s\x00icon\x1fimage-x-generic\n" "$name"
        fi
    done
}

# Navigate and select
navigate_and_select() {
    local dir="$WALLPAPER_DIR"
    
    while true; do
        choice=$(generate_menu "$dir" | rofi -dmenu -show -i -theme "$ROFI_THEME" -p "Wallpapers: ${current_dir#$WALLPAPER_DIR/}" | sed 's/\x00.*//')
        [[ -z "$choice" ]] && return 1

        echo "SELECTED: $choice" >&2

        case "$choice" in
            ".. (back)")
                dir=$(dirname "$dir")
                [[ "$dir" != "$WALLPAPER_DIR"* ]] && dir="$WALLPAPER_DIR"
                ;;
            ". random")
                collect_wallpapers "$dir"
                if [[ ${#PICS[@]} -gt 0 ]]; then
                    echo "${PICS[$((RANDOM % ${#PICS[@]}))]}"
                    return 0
                fi
                ;;
            */)
                # Folder navigation
                new_dir="$dir/${choice%/}"
                [[ -d "$new_dir" ]] && dir="$new_dir"
                ;;
            *)
                # File selection
                file_path="$dir/$choice"
                if [[ -f "$file_path" ]]; then
                    echo "$file_path"
                    return 0
                else
                    notify-send "Error" "File not found: $choice"
                fi
                ;;
        esac
    done
}

# Apply image wallpaper
apply_image_wallpaper() {
    local image_path="$1"
    
    kill_wallpaper_processes
    
    if ! pgrep -x "hyprpaper" >/dev/null; then
        hyprpaper &
        sleep 1
    fi
    
    while IFS= read -r monitor; do
        hyprctl hyprpaper preload "$image_path" 2>/dev/null
        hyprctl hyprpaper wallpaper "$monitor,$image_path" 2>/dev/null
    done < <(get_monitors)
    
    mkdir -p "$(dirname "$WALLPAPER_CURRENT")"
    cp "$image_path" "$WALLPAPER_CURRENT"
    
    [[ -f "$SCRIPTS_DIR/WallustSwww.sh" ]] && "$SCRIPTS_DIR/WallustSwww.sh"
    [[ -f "$SCRIPTS_DIR/Refresh.sh" ]] && "$SCRIPTS_DIR/Refresh.sh"
    
    notify-send "Wallpaper" "Applied: $(basename "$image_path")"
}
# Main function
main() {
    pkill rofi 2>/dev/null
    
    # Optional: clean up old thumbnails (uncomment if needed)
    # cleanup_old_thumbnails
    
    local selected_file
    selected_file=$(navigate_and_select)
    
    if [[ -z "$selected_file" || ! -f "$selected_file" ]]; then
        exit 1
    fi
    
    apply_image_wallpaper "$selected_file"
    wallust run "$selected_file"
}

main
