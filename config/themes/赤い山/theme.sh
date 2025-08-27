#!/bin/bash

cp -r ~/.config/hypr/styles/waybar/default.css ~/.config/waybar/style.css
cp -r ~/.config/hypr/styles/waybar/defaultConfig ~/.config/waybar/config

bash ~/.config/hypr/scripts/wallpaper.sh -s ~/.config/hypr/wallpapers/赤い山.jpg

scheme="akaiyama"

sed -i "s/vim\.cmd(\"colorscheme .*\")/vim.cmd(\"colorscheme $scheme\")/" ~/.config/nvim/init.lua
