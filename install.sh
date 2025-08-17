#!/bin/bash

set -euo pipefail

# Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

info() { echo -e "${GREEN}➤ $1${RESET}"; }
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

# Update system
info "Updating system..."
if ! check_dep yay; then
    
    error "'yay' is not installed.\n"

    if gum confirm "Install yay?"; then
        info "Installing dependecies..."
        sudo pacman -S --needed base-devel git
        info "Cloning yay.git..."
        git clone https://aur.archlinux.org/yay.git
        info "Building package..."
        cd yay
        makepkg -si
        cd ..
        rm -rf yay
        info "Package (yay) installed."
    else
        error "Aborting setup."
        exit 1
    fi
fi

if ! yay -Syu --noconfirm >/dev/null 2>&1; then
    error "System update failed. Try to update manually."
    exit 1
fi

# Packages
PACKAGES=(
    breeze nwg-look qt6ct papirus-icon-theme bibata-cursor-theme catppuccin-gtk-theme-mocha
    ttf-jetbrains-mono-nerd ttf-jetbrains-mono ttf-fira-code otf-fira-code-symbol ttf-material-design-iconic-font
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
info "Cloning Repository..."
rm -rf ./hyprdots
if ! git clone https://github.com/BinaryHarbinger/hyprdots.git; then
    error "Failed to clone repository."
    exit 1
fi
    cd hyprdots || { error "Cannot enter dotfiles directory"; exit 1; }

# Layout update
LAYOUT=$(localectl status | awk -F': ' '/X11 Layout/{print $2}')
if [[ -z $LAYOUT ]]; then
    error "Could not detect keyboard layout."
else
    info "Updating layout in hyprland.conf..."
    sed -i "s/kb_layout = tr/kb_layout = ${LAYOUT}/g" ./config/hypr/hyprland.conf
fi

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

ln -sf "$HOME/.config/hypr/wallpapers/lines.jpg" "$HOME/.config/hypr/wallppr.png"

# Change shell
if gum confirm "Change default shell to fish?"; then
    if chsh -s /bin/fish "$USER"; then
        info "Default shell changed to fish."
    else
        error "Failed to change shell."
    fi
fi

# Restart services
info "Reloading components..."

if pgrep waybar >/dev/null 2>&1; then
    pkill waybar >/dev/null 2>&1 || true
fi
(waybar & disown) >/dev/null 2>&1 || true

if ! swww-daemon >/dev/null 2>&1 & disown; then
    error "swww-daemon failed"
else
    swww img ~/.config/hypr/wallpapers/Lines.png --transition-fps 60 --transition-step 255 --transition-type any
fi

sleep 1
pgrep eww >/dev/null && killall eww && eww daemon  >/dev/null 2>&1 && eww open-many stats desktopmusic  >/dev/null 2>&1

# Cleanup
info "Cleaning up..."
cd ..
rm -rf hyprdots

info "✅ Installation complete! Please restart your session."
