#!/usr/bin/env bash

cd ~

# Usage Information
usage() {
    echo "Usage: $0 [--drun | --run | --menu]"
    echo ""
    echo "  --drun   : Launches the application launcher (drun)."
    echo "  --run    : Launches the command runner (run)."
    echo "  --menu   : Displays a custom menu with multiple options."
    echo "  --window : Displays a open windows."
    exit 1
}

# Function: DRUN Launcher
drun_launcher() {
    rofi \
        -show drun \
        -theme ~/.config/rofi/launcher.rasi
}

# Function: RUN Launcher
run_launcher() {
    rofi \
        -show run \
        -theme ~/.config/rofi/launcher.rasi
}

# Function: CONFIRMATION Launcher
conf_launcher() {
    rofi \
    -show run \
    -theme ~/.config/rofi/confirm.rasi
}

# Function: Custom Menu
custom_menu() {
    # Menu options displayed in rofi
    options="\n\n\n\n\n"

    # Prompt user to choose an option
    chosen=$(echo -e "$options" | rofi -config ~/.config/rofi/submenu.rasi -dmenu -p "Select an option:")

    # Execute the corresponding command based on the selected option
    case $chosen in
        "")
            rofi -show drun
            ;;
        "")
            thunar
            ;;
        "")
            wlogout
            ;;
        "")
            foot
            ;;
        "")
            bash ~/.config/hypr/scripts/openBrowser.sh
            ;;
        "")
            ~/.config/hypr/scripts/help
            ;;
        *)
            echo "No option selected"
            ;;
    esac
}

widget_settings() {
    # Menu options displayed in rofi
    options="󰌍\n Desk Clock\n Change Stats\n Change Music\n Reload Widgets\n Initalize"

    # Prompt user to choose an option
    chosen=$(echo -e "$options" | rofi -config ~/.config/rofi/sysmenu.rasi -dmenu -p "Select an option:")

    # Execute the corresponding command based on the selected option
    case $chosen in
        "󰌍")
            rice_settings
            ;;
        " Desk Clock")
            bash ~/.config/hypr/scripts/widgets.sh three
            bash ~/.config/hypr/scripts/widgets.sh r
            widget_settings
            ;;
        " Change Stats")
            bash ~/.config/hypr/scripts/widgets.sh one
            bash ~/.config/hypr/scripts/widgets.sh r
            widget_settings
            ;;
        " Change Music")
            bash ~/.config/hypr/scripts/widgets.sh two
            bash ~/.config/hypr/scripts/widgets.sh r
            widget_settings
            ;;
        " Reload Widgets")
            bash ~/.config/hypr/scripts/widgets.sh r
            ;;
        " Initalize Widgets")
            bash ~/.config/hypr/scripts/widgets.sh r
            ;;
        *)
            echo "No option selected"
            ;;
    esac 
}

waybar_settings() {
    # Menu options displayed in rofi
    options=" Single Bar\n Windows\n Simple Bar\n Binary Bar\n Floating Bar\n Reload Bar"

    # Prompt user to choose an option
    chosen=$(echo -e "$options" | rofi -config ~/.config/rofi/sysmenu.rasi -dmenu -p "Select an option:")

    # Execute the corresponding command based on the selected option
    case $chosen in
        " Single Bar")
            cp -r ~/.config/hypr/styles/waybar/bar.css ~/.config/waybar/style.css
            cp -r ~/.config/hypr/styles/waybar/barConfig ~/.config/waybar/config
            ;;
        " Binary Bar")
            cp -r ~/.config/hypr/styles/waybar/default.css ~/.config/waybar/style.css
            cp -r ~/.config/hypr/styles/waybar/defaultConfig ~/.config/waybar/config
            ;;
        " Floating Bar")
            cp -r ~/.config/hypr/styles/waybar/floating.css ~/.config/waybar/style.css
            cp -r ~/.config/hypr/styles/waybar/floatConfig ~/.config/waybar/config
            ;;
        " Simple Bar")
            cp -r ~/.config/hypr/styles/waybar/simple.css ~/.config/waybar/style.css
            cp -r ~/.config/hypr/styles/waybar/simpleConfig ~/.config/waybar/config
            ;;
        " Windows")
            cp -r ~/.config/hypr/styles/waybar/windows.css ~/.config/waybar/style.css
            cp -r ~/.config/hypr/styles/waybar/windowsConfig ~/.config/waybar/config
            ;;
        " Reload Bar")
        pkill waybar
        waybar& disown
            ;;
        *)
            echo "No option selected"
            ;;
        esac

        if [[ -n "$chosen" ]]; then
            pkill waybar
            waybar & disown
        fi
}

rice_settings() {
    # Menu options displayed in rofi
    options="󰌍\n Widgets\n Waybar Themes\n Wallpaper\n Themes"

    # Prompt user to choose an option
    chosen=$(echo -e "$options" | rofi -config ~/.config/rofi/sysmenu.rasi -dmenu -p "Select an option:")

    # Execute the corresponding command based on the selected option
    case $chosen in
        "󰌍")
            system_menu
            ;;
        " Widgets")
            widget_settings
            ;;
        " Waybar Themes")
            waybar_settings
            ;;

        " Themes")
            theme_menu
            ;;
        " Wallpaper")
            set_wallpaper
            ;;
        *)
            echo "No option selected"
            ;;
    esac
}

wallpaper_settings() {
    # Menu options displayed in rofi
    options=" Lines\n Waves\n Patterns"

    # Prompt user to choose an option
    chosen=$(python ~/.config/hypr/scripts/wallpapers.py | rofi -config ~/.config/rofi/sysmenu.rasi -dmenu -p "Select an option:")

    # Execute the corresponding command based on the selected option
    case $chosen in
        " Lines")
            bash ~/.config/hypr/scripts/wallpaper.sh -s ~/.config/hypr/wallpapers/lines.png
            ;;
        " Waves")
        bash ~/.config/hypr/scripts/wallpaper.sh -s ~/.config/hypr/wallpapers/waves.png
            ;;
        " Patterns")
        bash ~/.config/hypr/scripts/wallpaper.sh -s .config/hypr/wallpapers/bgpatternblue.jpg
            ;;
        *)
            echo "No option selected"
            ;;
    esac
}

set_wallpaper() {

    # Prompt user to choose an option
    chosen=$(python ~/.config/hypr/scripts/wallpapers.py echoImageNames | rofi -config ~/.config/rofi/sysmenu.rasi -dmenu -p "Select an option:")
    # Execute the corresponding command based on the selected option
    echo $chosen
    python ~/.config/hypr/scripts/wallpapers.py changeWallpaper $chosen
}

maintain_menu() {
    # Menu options displayed in rofi
    options="󰌍\nClear Cache\nClear Clipboard\nUpdate Rice\nUpdate System"

    # Prompt user to choose an option
    chosen=$(echo -e "$options" | rofi -config ~/.config/rofi/sysmenu.rasi -dmenu -p "Select an option:")

    # Execute the corresponding command based on the selected option
    case $chosen in
        "󰌍")
            system_menu
            ;;

        "Clear Cache")
            yay -Scc --no-confirm
         	find ~/.cache -mindepth 1 -maxdepth 1 \
         	  ! -name "spotify" \
         	  ! -name "cliphist" \
         	  ! -name "yay" \
         	  ! -name "mcpelauncher-webview"\
         	  ! -name "pip" \
         	  ! -name "rofi-entry-history.txt" \
         	  ! -name "Hyprland Polkit Agent" \
         	  ! -name "spotube" \
         	  ! -name "oss.krtirtho.spotube" \
         	  -exec rm -rf {} +
            maintain_menu
            ;;
        "Clear Clipboard")
            rm -rf ~/.cache/cliphist
            maintain_menu
            ;;
        "Update System")
            foot --override=colors.alpha=1 --app-id=Update -e bash ~/.config/scripts/update
            ;;
        "Update Rice")
            curl -sSL https://raw.githubusercontent.com/BinaryHarbinger/hyprdots/refs/heads/main/install.sh -o install.sh
            foot --override=colors.alpha=1 --app-id=Update -e bash ./install.sh
            rm -rf ./install.sh
                    ;;
        *)
            echo "No option selected"
            ;;
    esac
}


system_menu() {
    # Menu options displayed in rofi
    options="󰃢 Maintaining\n󰅇 Clear Clipboard\n Session Options\n Rice Settings\n Update System"

    # Prompt user to choose an option
    chosen=$(echo -e "$options" | rofi -config ~/.config/rofi/sysmenu.rasi -dmenu -p "Select an option:")

    # Execute the corresponding command based on the selected option
    case $chosen in
        "󰃢 Maintaining")
            maintain_menu
            ;;
        "󰅇 Clear Clipboard")
            rm -rf ~/.cache/cliphist
            ;;
        " Session Options")
            wlogout
            ;;
        " Update System")
            foot --override=colors.alpha=1 --app-id=Update -e bash ~/.config/scripts/update
            ;;
        " Rice Settings")
            rice_settings
                    ;;
        *)
            echo "No option selected"
            ;;
    esac
}

theme_menu() {
   THEME_DIR="$HOME/.config/themes"

    # Menu options displayed in rofi
    THEMES=$(find "$THEME_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n')

    # Prompt user to choose an option
    chosen=$(echo -e "$THEMES" | rofi -config ~/.config/rofi/sysmenu.rasi -dmenu -p "Themes")
    
    if [[ -z "$chosen" ]]; then 
        exit 1 
    fi

    THEME_PATH="$THEME_DIR/$chosen"
    cp -r $THEME_PATH/theme.scss ~/.config/eww/ 
    cp -r $THEME_PATH/theme.css ~/.config/waybar/
    cp -r $THEME_PATH/theme.css ~/.config/wlogout/ 
    cp -r $THEME_PATH/theme.css ~/.config/swaync/ 
    cp -r $THEME_PATH/theme.rasi ~/.config/rofi/ 
    cp -r $THEME_PATH/hypr.conf ~/.config/hypr/theme.conf
    cp -r $THEME_PATH/wiremix.toml ~/.config/wiremix/ 
    cp -r $THEME_PATH/foot.ini ~/.config/foot/
    cp -r $THEME_PATH/theme.toml ~/.config/yazi/theme.toml
    cp -r $THEME_PATH/fish/* ~/.config/fish/
    bash $THEME_PATH/theme.sh

    eww r >/dev/null 2>&1 & disown
    pkill waybar >/dev/null 2>&1
    waybar >/dev/null 2>&1 & disown
    swaync-client --reload-css | swaync-client --reload-css | swaync-client --reload-css

    notify-send -u normal "🎨 Theme Changed" "" -i preferences-desktop-theme

}



# Check for flags and validate input
if [[ $# -ne 1 ]]; then
    usage
fi

# Execute the appropriate function based on the provided flag
case "$1" in
    --drun)
        drun_launcher
        ;;
    --window)
        rofi \
        -show window \
        -theme ~/.config/rofi/window.rasi
        ;;

    --run)
        run_launcher
        ;;
    --menu)
        custom_menu
        ;;
    --widget_settings)
    	widget_settings
    	;;
     --rice_settings)
     	rice_settings
     	;;
     --system_menu)
     	system_menu
     	;;
    *)
        usage
        ;;
esac
