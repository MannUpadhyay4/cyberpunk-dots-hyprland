#!/bin/bash
# ~/.config/hypr/scripts/kitty-sounds.sh - No cooldown, instant sounds

HYPR_DIR="/run/user/$(id -u)/hypr"
SOCKET_PATH=$(find "$HYPR_DIR" -name ".socket2.sock" | head -1)

get_kitty_count() {
    hyprctl clients -j 2>/dev/null | jq -r '[.[] | select(.class=="kitty")] | length' || echo 0
}

CURRENT_COUNT=$(get_kitty_count)

# Fast monitoring with instant sounds
while true; do
    NEW_COUNT=$(get_kitty_count)
    
    if (( NEW_COUNT > CURRENT_COUNT )); then
        # Play sound for each new window
        for ((i=CURRENT_COUNT; i<NEW_COUNT; i++)); do
            paplay ~/Documents/Open.wav 2>/dev/null &
        done
    elif (( NEW_COUNT < CURRENT_COUNT )); then
        # Play sound for each closed window  
        for ((i=NEW_COUNT; i<CURRENT_COUNT; i++)); do
            paplay ~/Documents/Close.wav 2>/dev/null &
        done
    fi
    
    CURRENT_COUNT=$NEW_COUNT
    sleep 0.1  # Fast polling
done
