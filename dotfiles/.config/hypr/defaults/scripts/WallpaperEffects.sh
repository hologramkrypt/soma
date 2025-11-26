#!/bin/sh
# Optimized Wallpaper Effects with High-Res Support (SUPER SHIFT K) - Current Wallpaper Fix

# Variables
terminal=ghostty
wallpaper_current="$HOME/.config/hypr/configs/appearance/wallpaper_effects/.wallpaper_current"
wallpaper_output="$HOME/.config/hypr/configs/appearance/wallpaper_effects/.wallpaper_modified"
SCRIPTSDIR="$HOME/.config/hypr/scripts"

# Get ALL monitors
monitors=($(hyprctl monitors -j | jq -r '.[].name'))
focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
rofi_theme="$HOME/.config/rofi/config-wallpaper-effect.rasi"

# Cache directory for pre-rendered effects
CACHE_DIR="$HOME/.cache/wallpaper_effects"
mkdir -p "$CACHE_DIR"

# Directory for swaync
iDIR="$HOME/.config/swaync/images"
iDIRi="$HOME/.config/swaync/icons"

# Get monitor resolution for high-quality effects (use first monitor as reference)
monitor_info=$(hyprctl monitors -j | jq '.[0]')
monitor_width=$(echo "$monitor_info" | jq -r '.width')
monitor_height=$(echo "$monitor_info" | jq -r '.height')
monitor_scale=$(echo "$monitor_info" | jq -r '.scale')

# Calculate optimal processing dimensions for performance
if (( monitor_width > 3840 )); then
    process_width=2560
    process_height=1440
elif (( monitor_width > 2560 )); then
    process_width=1920
    process_height=1080
else
    process_width=$monitor_width
    process_height=$monitor_height
fi

# Enhanced ImageMagick effects for high resolution
declare -A effects=(
    ["No Effects"]="no-effects"
    ["Black & White"]="magick '$wallpaper_current' -resize ${process_width}x${process_height} -colorspace gray -sigmoidal-contrast 7,50% -resize ${monitor_width}x${monitor_height} '$wallpaper_output'"
    ["Cinematic B&W"]="magick '$wallpaper_current' -resize ${process_width}x${process_height} -colorspace gray -contrast-stretch 1% -gamma 1.2 -resize ${monitor_width}x${monitor_height} '$wallpaper_output'"
    ["Blurred Background"]="magick '$wallpaper_current' -resize ${process_width}x${process_height} -blur 0x15 -resize ${monitor_width}x${monitor_height} '$wallpaper_output'"
    ["Depth Blur"]="magick '$wallpaper_current' -resize ${process_width}x${process_height} \( +clone -blur 0x20 \) +swap -compose overlay -composite -resize ${monitor_width}x${monitor_height} '$wallpaper_output'"
    ["Charcoal Sketch"]="magick '$wallpaper_current' -resize ${process_width}x${process_height} -charcoal 2 -colorspace Gray -resize ${monitor_width}x${monitor_height} '$wallpaper_output'"
    ["Oil Painting"]="magick '$wallpaper_current' -resize ${process_width}x${process_height} -paint 3 -sharpen 0x1 -resize ${monitor_width}x${monitor_height} '$wallpaper_output'"
    ["Vibrant Boost"]="magick '$wallpaper_current' -resize ${process_width}x${process_height} -modulate 110,120,100 -contrast-stretch 1% -resize ${monitor_width}x${monitor_height} '$wallpaper_output'"
    ["Muted Tones"]="magick '$wallpaper_current' -resize ${process_width}x${process_height} -modulate 90,80,100 -gamma 0.9 -resize ${monitor_width}x${monitor_height} '$wallpaper_output'"
    ["Sepia Vintage"]="magick '$wallpaper_current' -resize ${process_width}x${process_height} -sepia-tone 80% -gamma 1.1 -resize ${monitor_width}x${monitor_height} '$wallpaper_output'"
    ["Cool Tone"]="magick '$wallpaper_current' -resize ${process_width}x${process_height} -color-matrix '0.7 0 0 0 0.9 0 0 0 1.2' -resize ${monitor_width}x${monitor_height} '$wallpaper_output'"
    ["Warm Tone"]="magick '$wallpaper_current' -resize ${process_width}x${process_height} -color-matrix '1.2 0 0 0 0.8 0 0 0 0.7' -resize ${monitor_width}x${monitor_height} '$wallpaper_output'"
    ["High Contrast"]="magick '$wallpaper_current' -resize ${process_width}x${process_height} -sigmoidal-contrast 5,50% -resize ${monitor_width}x${monitor_height} '$wallpaper_output'"
    ["Soft Pastel"]="magick '$wallpaper_current' -resize ${process_width}x${process_height} -modulate 105,85,100 -blur 0x3 -resize ${monitor_width}x${monitor_height} '$wallpaper_output'"
    ["Dramatic Vignette"]="magick '$wallpaper_current' -resize ${process_width}x${process_height} -background black -vignette 0x8+100+100 -resize ${monitor_width}x${monitor_height} '$wallpaper_output'"
    ["Film Grain"]="magick '$wallpaper_current' -resize ${process_width}x${process_height} -noise 2 -blur 0x0.7 -resize ${monitor_width}x${monitor_height} '$wallpaper_output'"
    ["Pixel Art"]="magick '$wallpaper_current' -resize ${process_width}x${process_height} -resize 25% -scale 400% -resize ${monitor_width}x${monitor_height} '$wallpaper_output'"
    ["HDR Effect"]="magick '$wallpaper_current' -resize ${process_width}x${process_height} -auto-level -sigmoidal-contrast 5,50% -resize ${monitor_width}x${monitor_height} '$wallpaper_output'"
)

# Function to get the ACTUAL current wallpaper from hyprpaper
get_current_wallpaper() {
    # First check if we have a valid current wallpaper file
    if [[ -f "$wallpaper_current" && -s "$wallpaper_current" ]]; then
        echo "$wallpaper_current"
        return 0
    fi
    
    # If not, try to get it from hyprpaper state or hyprctl
    local hyprpaper_state=$(hyprctl hyprpaper list active 2>/dev/null)
    if [[ -n "$hyprpaper_state" ]]; then
        local wall_path=$(echo "$hyprpaper_state" | grep -oP "wallpaper: \K[^,]+" | head -1)
        if [[ -f "$wall_path" ]]; then
            # Copy to our current wallpaper file
            cp "$wall_path" "$wallpaper_current"
            echo "$wallpaper_current"
            return 0
        fi
    fi
    
    # Last resort: use the most recent wallpaper from wallpapers directory
    local recent_wallpaper=$(find "$HOME/.wallpapers" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -printf "%T@ %p\n" 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-)
    if [[ -f "$recent_wallpaper" ]]; then
        cp "$recent_wallpaper" "$wallpaper_current"
        echo "$wallpaper_current"
        return 0
    fi
    
    # Final fallback
    echo "$wallpaper_current"
}

# Function to apply no effects (optimized)
no-effects() {
    # Get the actual current wallpaper
    local current_wall=$(get_current_wallpaper)
    
    if [[ ! -f "$current_wall" || ! -s "$current_wall" ]]; then
        notify-send -u critical -i "$iDIR/error.png" "Error" "No valid wallpaper found"
        return 1
    fi
    
    # Use hyprpaper for faster no-effects application on ALL monitors
    hyprctl hyprpaper preload "$current_wall"
    for monitor in "${monitors[@]}"; do
        hyprctl hyprpaper wallpaper "$monitor,$current_wall" &
    done
    wait
    
    wallust run "$current_wall" -s &
    
    # Copy for consistency
    cp "$current_wall" "$wallpaper_output"
    
    # Refresh in parallel
    {
        sleep 1
        "$SCRIPTSDIR/Refresh.sh"
        notify-send -u low -i "$iDIR/ja.png" "No wallpaper" "effects applied to ${#monitors[@]} monitors"
    } &
    
    wait
}

# Function to get effect cache key
get_cache_key() {
    local effect_name="$1"
    local current_wall=$(get_current_wallpaper)
    
    if [[ ! -f "$current_wall" || ! -s "$current_wall" ]]; then
        notify-send -u critical -i "$iDIR/error.png" "Error" "No valid wallpaper for cache key"
        return 1
    fi
    
    local wallpaper_hash=$(md5sum "$current_wall" | cut -d' ' -f1)
    local resolution_key="${monitor_width}x${monitor_height}"
    echo "${effect_name}_${wallpaper_hash}_${resolution_key}"
}

# Function to apply effect with caching
apply_effect() {
    local effect_name="$1"
    local effect_command="$2"
    
    # Get the actual current wallpaper
    local current_wall=$(get_current_wallpaper)
    
    if [[ ! -f "$current_wall" || ! -s "$current_wall" ]]; then
        notify-send -u critical -i "$iDIR/error.png" "Error" "No valid wallpaper found to apply effects to"
        return 1
    fi
    
    local cache_key=$(get_cache_key "$effect_name")
    local cache_file="$CACHE_DIR/${cache_key}.png"
    
    # Check cache first
    if [[ -f "$cache_file" && "$cache_file" -nt "$current_wall" ]]; then
        cp "$cache_file" "$wallpaper_output"
        echo "✓ Used cached effect: $effect_name"
        return 0
    fi
    
    # Apply effect and cache result
    notify-send -u normal -i "$iDIR/ja.png" "Rendering:" "$effect_name"
    
    # Time the effect application
    local start_time=$(date +%s%3N)
    
    # Use the actual current wallpaper in the effect command
    local updated_command=$(echo "$effect_command" | sed "s|$wallpaper_current|$current_wall|g")
    
    if eval "$updated_command"; then
        local end_time=$(date +%s%3N)
        local duration=$((end_time - start_time))
        echo "✓ Effect applied in ${duration}ms: $effect_name"
        
        # Cache the result for future use
        cp "$wallpaper_output" "$cache_file" &
        return 0
    else
        notify-send -u critical -i "$iDIR/error.png" "Error" "Failed to apply $effect_name"
        return 1
    fi
}

# Function to apply wallpaper to ALL monitors in hyprpaper
apply_wallpaper_to_all_monitors() {
    local wallpaper_path="$1"
    
    # Ensure hyprpaper is running
    if ! pgrep -x "hyprpaper" >/dev/null; then
        hyprpaper &
        sleep 0.5
    fi
    
    # Clear hyprpaper cache and preload fresh
    hyprctl hyprpaper unload all
    hyprctl hyprpaper preload "$wallpaper_path"
    
    # Apply to ALL monitors
    for monitor in "${monitors[@]}"; do
        hyprctl hyprpaper wallpaper "$monitor,$wallpaper_path"
    done
    
    echo "✓ Wallpaper applied to ${#monitors[@]} monitors: $wallpaper_path"
}

# Function to cleanup old cache files
cleanup_cache() {
    find "$CACHE_DIR" -name "*.png" -mtime +7 -delete 2>/dev/null &
}

# Function to clear all effects cache
clear_effects_cache() {
    rm -rf "$CACHE_DIR"/*.png 2>/dev/null
    notify-send -u low -i "$iDIR/ja.png" "Cache cleared" "All effect caches removed"
}

# Optimized function to run rofi menu
main() {
    # Cleanup old cache in background
    cleanup_cache
    
    # Kill existing rofi if running
    if pidof rofi >/dev/null; then
        pkill rofi
        sleep 0.1
    fi

    # Create organized menu with categories
    {
        echo "🎯 Basic Effects"
        echo "No Effects"
        echo "Black & White" 
        echo "Blurred Background"
        echo "Vibrant Boost"
        echo "High Contrast"
        echo "🎨 Artistic"
        echo "Oil Painting"
        echo "Charcoal Sketch"
        echo "Pixel Art"
        echo "Film Grain"
        echo "🌈 Color Grading"
        echo "Sepia Vintage"
        echo "Cool Tone"
        echo "Warm Tone"
        echo "Muted Tones"
        echo "⚡ Advanced"
        echo "Depth Blur"
        echo "Dramatic Vignette"
        echo "Soft Pastel"
        echo "Cinematic B&W"
        echo "HDR Effect"
        echo "🔧 Utilities"
        echo "Clear Effects Cache"
    } | rofi -dmenu -i -config "$rofi_theme" | head -1
}

# Main execution
choice=$(main)

if [[ -n "$choice" ]]; then
    # Remove category markers if present
    choice=$(echo "$choice" | sed -E 's/^[🎯🎨🌈⚡🔧]+\s+//')
    
    case "$choice" in
        "No Effects")
            no-effects
            ;;
        "Clear Effects Cache")
            clear_effects_cache
            ;;
        *)
            if [[ -n "${effects[$choice]}" ]]; then
                if apply_effect "$choice" "${effects[$choice]}"; then
                    # Apply the modified wallpaper to ALL monitors
                    apply_wallpaper_to_all_monitors "$wallpaper_output"
                    
                    # Run wallust and refresh in parallel
                    {
                        wallust run "$wallpaper_output" -s
                        sleep 1
                        "$SCRIPTSDIR/Refresh.sh"
                        notify-send -u low -i "$iDIR/ja.png" "$choice" "effects applied to ${#monitors[@]} monitors"
                    } &
                fi
            else
                notify-send -u critical -i "$iDIR/error.png" "Error" "Effect '$choice' not found"
            fi
            ;;
    esac
fi

# Wait for all background processes
wait
