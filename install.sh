#!/bin/bash
set -e

# Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

info() { echo -e "${GREEN}➤ $1${RESET}"; }
error() { echo -e "${RED}✖ $1${RESET}"; }

# Check dependencies
if ! command -v gum >/dev/null 2>&1; then
    error "gum is not installed. Run: sudo pacman -S gum"
    exit 1
fi

echo "Binary Harbinger's Hyprland dotfiles"
gum confirm "Proceed with Hyprland dotfiles setup?" || exit 1

info "Updating system..."
yay -Syu --noconfirm --needed >/dev/null 2>&1 || error "System update failed"

PACKAGES=(
  breeze cliphist git nwg-look qt6ct fish power-profiles-daemon fastfetch ttf-jetbrains-mono-nerd ttf-jetbrains-mono
  ttf-fira-code otf-fira-code-symbol hyprland yazi micro rofi-wayland hyprlock hyprpolkitagent unzip hyprsunset rofimoji
  hyprpaper wlogout foot papirus-icon-theme base-devel waybar swaync mpv hyprpicker eww pamixer hypridle udiskie
  network-manager-applet pamixer brightnessctl swww bibata-cursor-theme catppuccin-gtk-theme-mocha ttf-material-design-iconic-font
)

if gum confirm "Install required packages?"; then
    info "Installing packages..."
    yay -S --noconfirm --needed "${PACKAGES[@]}"
fi

info "Setting up polkit agent..."
systemctl --user enable --now hyprpolkitagent.service || error "Failed to enable polkit agent"

if gum confirm "Clone BinaryHarbinger dotfiles repo?"; then
    git clone https://github.com/BinaryHarbinger/hyprdots.git
    cd hyprdots || { error "Cannot enter dotfiles directory"; exit 1; }
else
    exit 0
fi

info "Updating layout in hyprland.conf..."
LAYOUT=$(localectl status | grep 'X11 Layout' | awk '{print $3}')
sed -i "s/kb_layout = tr/kb_layout = ${LAYOUT}/g" ./hypr/hyprland.conf

info "Moving scripts and configs..."
cp -rf ./.scripts ~
chmod +x ~/.scripts/*

rm -rf ./preview
cp -rf ./* ~/.config/
chmod +x ~/.config/hypr/scripts/* ~/.config/eww/scripts/*

ln -sf "$HOME/.config/hypr/wallpapers/lines.jpg" "$HOME/.config/hypr/wallppr.png"

if gum confirm "Change default shell to fish?"; then
    sudo chsh -s /bin/fish "$USER"
fi

# Restart services
info "Reloading components..."

pgrep waybar && pkill waybar && waybar & disown
pgrep hyprpaper && pkill hyprpaper & disown

swww-daemon || error "swww-daemon failed"
swww img ~/.config/hypr/wallpapers/Lines.png --transition-fps 60 --transition-step 255 --transition-type any

sleep 1
pgrep eww && killall eww && eww daemon && eww open-many stats desktopmusic

info "Cleaning up..."
cd ..
rm -rf hyprdots

info "✅ Installation complete! Please restart your session."
