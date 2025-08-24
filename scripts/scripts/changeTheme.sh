#!/usr/bin/env bash

THEME_DIR="$HOME/.config/themes"
THEMES=$(find "$THEME_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n')

USAGE="\nUsage: $0 [OPTION] [ARGUMENT]

Options:
  -l, --list             List available themes
  -c, --change THEME     Change to specified THEME
  -h, --help             Show this help message
"
change_theme () {

    cp -r "$THEME_PATH/theme.scss" ~/.config/eww/
    cp -r "$THEME_PATH/theme.css" ~/.config/waybar/
    cp -r "$THEME_PATH/theme.css" ~/.config/wlogout/
    cp -r "$THEME_PATH/theme.css" ~/.config/swaync/
    cp -r "$THEME_PATH/theme.rasi" ~/.config/rofi/
    cp -r "$THEME_PATH/hypr.conf" ~/.config/hypr/theme.conf
    cp -r "$THEME_PATH/wiremix.toml" ~/.config/wiremix/
    cp -r "$THEME_PATH/foot.ini" ~/.config/foot/
    cp -r "$THEME_PATH/theme.toml" ~/.config/yazi/theme.toml
    cp -r "$THEME_PATH/fish/"* ~/.config/fish/
    bash "$THEME_PATH/theme.sh"

    eww reload >/dev/null 2>&1 & disown
    pkill waybar >/dev/null 2>&1
    waybar >/dev/null 2>&1 & disown
    swaync-client --reload-css || swaync-client --reload-css

    notify-send -u normal "🎨 Theme Changed" -i preferences-desktop-theme
    echo -e "Theme changed to $chosen"
}

case $1 in

    --list|-l)
        echo -e "Available themes:\n$THEMES"
        ;;

    --change|-c)
        chosen=$2

        if [[ -z "$chosen" ]]; then
            echo "No theme selected."
            exit 1
        fi

        THEME_PATH="$THEME_DIR/$chosen"
        if [[ ! -d "$THEME_PATH" ]]; then
            echo "Error: No such theme '$chosen'"
            echo -e "Available themes:\n$THEMES"
            exit 1
        fi

        change_theme
        ;;

    --help|-h)
        echo -e "$USAGE"
        ;;

    *)
        echo -e "Error: Unkown flag '$1'\n $USAGE"
esac
