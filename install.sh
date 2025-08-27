#!/bin/bash

set -euo pipefail

# Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

info() { echo -e "${GREEN}➤ $1${RESET}"; }
procces() { echo -e "${BLUE} $1${RESET}"; }
error() { echo -e "${RED}✖ $1${RESET}" >&2; }

echo -e "${BLUE}
░█▀▄░▀█▀░█▀█░█▀█░█▀▄░█░█░░░█▀▄░█▀█░▀█▀░█▀▀
░█▀▄░░█░░█░█░█▀█░█▀▄░░█░░░░█░█░█░█░░█░░▀▀█
░▀▀░░▀▀▀░▀░▀░▀░▀░▀░▀░░▀░░░░▀▀░░▀▀▀░░▀░░▀▀▀ \n${RESET}"

# Root check for necessary commands
if [[ $EUID -eq 0 ]]; then
    error "Please do not run this script as root.\n"
    exit 1
fi

# Dependency check
check_dep() {
    if ! command -v "$1" >/dev/null 2>&1; then
        error "'$1' is not installed."
        return 1
    fi
}

# Gum check & install
if ! check_dep gum; then
    info "Installing gum..."
    if ! sudo pacman -S --noconfirm gum; then
        error "Failed to install gum. Please install it manually."
        exit 1
    fi
fi

echo -e "   Binary Harbinger's Hyprland dotfiles\n\n"
gum confirm "Proceed with setup?" || exit 0

# Get sudo password
echo "Enter your sudo password:"
sudo echo
info "Succses"

# Update system
if ! check_dep yay; then
    
    if gum confirm "Install yay?"; then
        info "Installing dependecies..."
        sudo pacman -S --needed base-devel git
        gum spin --spinner dot --title "Cloning yay repository..." -- git clone https://aur.archlinux.org/yay.git
        info "Building package..."
        cd yay
        makepkg -si
        cd ..
        rm -rf yay
        info "Package (yay) installed."
    else
        error "Aborting setup."
        rm -rf yay 
        exit 1
    fi
fi

if gum spin --spinner dot --title "Updating system..." -- bash -c '
    if ! yay -Syu --noconfirm --repo >/dev/null 2>&1; then
        echo "System update failed. Try to update manually." >&2
        exit 1
    fi
'; then
    gum style --foreground "#49A22C" -- <<< "➤ System updated."
else
    gum style --foreground "#FF5555" -- <<< "✖ System update failed. Try manually."
    exit 1
fi

# Packages
PACKAGES=(
    breeze nwg-look qt6ct papirus-icon-theme bibata-cursor-theme catppuccin-gtk-theme-mocha
    ttf-jetbrains-mono-nerd ttf-jetbrains-mono ttf-fira-code ttf-firacode-nerd otf-fira-code-symbol ttf-material-design-iconic-font
    yazi wiremix
    hyprland hyprlock hypridle hyprpolkitagent hyprsunset hyprpicker
    wlogout
    power-profiles-daemon udiskie network-manager-applet brightnessctl
    cliphist stow git fish unzip fastfetch pamixer swaync mpv foot swww
    base-devel
    waybar eww
    rofi-wayland rofimoji
)

if gum confirm "Install required packages?"; then
    info "Installing packages..."
    if ! yay -S --noconfirm --needed "${PACKAGES[@]}"; then
        error "Package installation failed."
        exit 1
    fi
fi

# Polkit agent
info "Setting up polkit agent..."
systemctl --user enable --now hyprpolkitagent.service || error "Failed to enable polkit agent"

# Clone dotfiles
rm -rf ./hyprdots
if ! gum spin --spinner dot --title "Cloning hyprdots repository..." -- git clone https://github.com/BinaryHarbinger/hyprdots.git; then
    error "Failed to clone repository."
    exit 1
fi
    cd hyprdots || { error "Cannot enter dotfiles directory"; exit 1; }
     gum style --foreground "#49A22C" -- <<< "➤ Clonned Repository."

# Move scripts/configs
info "Moving scripts and configs..."
if [[ -d ./scripts ]]; then
    cp -rf ./scripts ~/.config/ || error "Failed to copy scripts"
    chmod +x ~/.config/scripts/* || true
else
    error "No scripts directory found."
fi

rm -rf ./preview
cp -rf ./config/* ~/.config/ || error "Failed to copy configs"
chmod +x ~/.config/hypr/scripts/* ~/.config/eww/scripts/* || true

# Layout update
LAYOUT=$(localectl status | awk -F': ' '/X11 Layout/{print $2}')

if [[ -z $LAYOUT ]]; then
    error "Could not detect keyboard layout."
else
    sed -i "s/kb_layout = tr/kb_layout = ${LAYOUT}/g" ./config/hypr/hyprland.conf
fi

ln -sf "$HOME/.config/hypr/wallpapers/lines.jpg" "$HOME/.config/hypr/wallppr.png"

# Change shell
current_shell=$(getent passwd "$USER" | cut -d: -f7)

if [ "$current_shell" != "/usr/bin/fish" ] && [ "$current_shell" != "/bin/fish" ]; then
    if gum confirm "Change default shell to fish?"; then
        if chsh -s /bin/fish "$USER"; then
            info "Default shell changed to fish."
        else
            error "Failed to change shell."
        fi
    fi
fi

# Post installation

python ~/.config/hypr/scripts/wallpapers.py changeWallpaper Lines >/dev/null 2>&1 & disown

if pgrep Hyprland >/dev/null; then
    info "Detected Hyprland session."

   gum spin --spinner dot --title "Reloading Components..." -- bash -c '
    
    pkill waybar >/dev/null 2>&1 & disown
    
    # swww-daemon restart
    if pgrep swww-daemon >/dev/null; then
        pkill swww-daemon
        sleep 0.5
    fi 

    # eww restart
    if pgrep eww >/dev/null; then
        killall eww
        eww daemon >/dev/null 2>&1 &
        disown
        eww open-many stats desktopmusic >/dev/null 2>&1
    fi
    waybar >/dev/null 2>&1 & disown
    swww-daemon >/dev/null 2>&1 & disown'

    gum style --foreground "#49A22C" -- <<< "➤ Reloaded Components."
fi

# Cleanup
cd ..
gum spin --spinner dot --title "Cleaning up..." -- rm -rf hyprdots
gum style --foreground "#49A22C" -- <<< "➤ Cleaned."

bash $HOME/.config/scripts/changeTheme.sh -p
echo -e  "${GREEN}✅ Installation complete!"
