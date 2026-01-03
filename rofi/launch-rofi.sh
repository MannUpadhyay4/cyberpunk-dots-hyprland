#!/bin/bash

# ================================
# Spotify Rofi Integration Script
# ================================

# Paths
CONFIG_DIR="$HOME/.config/rofi"
ASSETS_DIR="$CONFIG_DIR/assets"
CACHE_DIR="$HOME/.cache/rofi/covers"
COVER_DEFAULT="$ASSETS_DIR/jhonny.png"
COVER_BACKUP="$ASSETS_DIR/jhonny1.png"
COVER_CURRENT="$ASSETS_DIR/jhonny.png"
CONFIG_TEMPLATE="$CONFIG_DIR/config.rasi"
CONFIG_RUNTIME="/tmp/rofi-spotify.rasi"

# Create cache directory
mkdir -p "$CACHE_DIR"

# Cache cleanup (remove files older than 7 days)
find "$CACHE_DIR" -type f -mtime +7 -delete 2>/dev/null

# Download timeout (seconds)
DOWNLOAD_TIMEOUT=2

# ================================
# Functions
# ================================

get_metadata() {
    ARTIST=$(playerctl -p spotify metadata artist 2>/dev/null)
    TITLE=$(playerctl -p spotify metadata title 2>/dev/null)
    ALBUM=$(playerctl -p spotify metadata album 2>/dev/null)
    STATUS=$(playerctl -p spotify status 2>/dev/null)
    
    # Get Spotify volume (0.0 to 1.0)
    SPOTIFY_VOL=$(playerctl -p spotify volume 2>/dev/null)
    if [ -n "$SPOTIFY_VOL" ]; then
        VOLUME=$(echo "$SPOTIFY_VOL * 100" | bc | cut -d. -f1)
    else
        VOLUME="0"
    fi
    
    ARTWORK_URL=$(playerctl -p spotify metadata mpris:artUrl 2>/dev/null | sed -e 's/open.spotify.com/i.scdn.co/g')
}

generate_cache_key() {
    echo -n "$ALBUM" | md5sum | awk '{print $1}'
}

download_cover() {
    local url="$1"
    local output="$2"
    local timeout="$3"
    
    timeout "$timeout" curl -s -f -o "$output" "$url" 2>/dev/null
    return $?
}

update_cover() {
    local cache_key=""
    local cached_file=""
    
    if [ "$STATUS" = "Playing" ] || [ "$STATUS" = "Paused" ]; then
        if [ -n "$ARTWORK_URL" ]; then
            cache_key=$(generate_cache_key)
            cached_file="$CACHE_DIR/${cache_key}.jpg"
            
            if [ -f "$cached_file" ]; then
                cp "$cached_file" "$COVER_CURRENT"
            else
                if download_cover "$ARTWORK_URL" "$COVER_CURRENT" "$DOWNLOAD_TIMEOUT"; then
                    cp "$COVER_CURRENT" "$cached_file"
                else
                    cp "$COVER_BACKUP" "$COVER_CURRENT"
                fi
            fi
        else
            cp "$COVER_BACKUP" "$COVER_CURRENT"
        fi
    else
        cp "$COVER_BACKUP" "$COVER_CURRENT"
    fi
}

generate_config() {
    local track_display="NO TRACK PLAYING"
    local volume_display="00"
    volume_display=$(pactl --format=json get-sink-volume @DEFAULT_SINK@ | jq -r '.volume."front-left".value_percent')
    if [ "$STATUS" = "Playing" ] || [ "$STATUS" = "Paused" ]; then
        local title_truncated=$(echo "$TITLE" | cut -c1-30)
        track_display="$title_truncated"
        echo $(volume_display)
    fi
    
    sed -e "s|NO TRACK PLAYING|$track_display|g" \
        -e "s|00%|${volume_display}|g" \
        -e "s|filename: \".*\";|filename: \"$COVER_CURRENT\";|g" \
        "$CONFIG_TEMPLATE" > "$CONFIG_RUNTIME"
}

spotify_control() {
    local action="$1"
    
    case "$action" in
        "play-pause")
            playerctl -p spotify play-pause
            ;;
        "next")
            playerctl -p spotify next
            ;;
        "prev")
            playerctl -p spotify previous
            ;;
        "vol-up")
            CURRENT=$(playerctl -p spotify volume 2>/dev/null)
            if [ -z "$CURRENT" ]; then
                exit 0
            fi
            NEW=$(echo "$CURRENT + 0.05" | bc)
            if (( $(echo "$NEW > 1.0" | bc -l) )); then
                NEW="1.0"
            fi
            playerctl -p spotify volume "$NEW"
            
            PERCENTAGE=$(echo "$NEW * 100" | bc | cut -d. -f1)
            notify-send -t 1000 -h string:x-canonical-private-synchronous:spotify-volume \
                "SPOTIFY VOLUME" "${PERCENTAGE}%"
            ;;
        "vol-down")
            CURRENT=$(playerctl -p spotify volume 2>/dev/null)
            if [ -z "$CURRENT" ]; then
                exit 0
            fi
            NEW=$(echo "$CURRENT - 0.05" | bc)
            if (( $(echo "$NEW < 0.0" | bc -l) )); then
                NEW="0.0"
            fi
            playerctl -p spotify volume "$NEW"
            
            PERCENTAGE=$(echo "$NEW * 100" | bc | cut -d. -f1)
            notify-send -t 1000 -h string:x-canonical-private-synchronous:spotify-volume \
                "SPOTIFY VOLUME" "${PERCENTAGE}%"
            ;;
        "show-info")
            ARTIST=$(playerctl -p spotify metadata artist 2>/dev/null)
            TITLE=$(playerctl -p spotify metadata title 2>/dev/null)
            ALBUM=$(playerctl -p spotify metadata album 2>/dev/null)
            
            if [ -n "$TITLE" ]; then
                notify-send -t 5000 "NOW PLAYING" "$TITLE\n$ARTIST\n$ALBUM"
            else
                notify-send -t 2000 "SPOTIFY" "NO TRACK PLAYING"
            fi
            ;;
    esac
}

# ================================
# Main Script
# ================================

# Check if running as control script
if [ "$1" = "control" ]; then
    spotify_control "$2"
    exit 0
fi

# Fetch current state and generate config
get_metadata
update_cover
generate_config

# Launch rofi
rofi -show drun -theme "$CONFIG_RUNTIME" 2>/dev/null
