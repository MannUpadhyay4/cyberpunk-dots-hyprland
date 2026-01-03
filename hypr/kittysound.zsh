#!/bin/bash

handle() {
    echo "Event received: $1"  # Debug output
    case $1 in
        openwindow*)
            class=$(echo $1 | cut -d',' -f3)
            echo "Window opened - class: $class"
            if [ "$class" = "kitty" ] || [ "$class" = "alacritty" ] || [ "$class" = "foot" ]; then
                echo "Playing open sound for terminal: $class"
                paplay ~/Documents/Open.wav &
            fi
        ;;
        closewindow*)
            class=$(echo $1 | cut -d',' -f2)
            echo "Window closed - class: $class"
            if [ "$class" = "kitty" ] || [ "$class" = "alacritty" ] || [ "$class" = "foot" ]; then
                echo "Playing close sound for terminal: $class"
                paplay ~/Documents/Close.wav &
            fi
        ;;
    esac
}

echo "Starting Hyprland event listener..."
echo "Socket: $XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do 
    handle "$line"
done
