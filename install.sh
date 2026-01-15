#!/bin/bash

# install.sh - Hyprland Config Installer

set -e # Exit on any error

echo "🚀 Installing Hyprland & Waybar configs..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
  print_error "This script should not be run as root!"
  exit 1
fi

# Check if in a git repository
if [ ! -d ".git" ]; then
  print_error "Not in a git repository. Run this script from your dotfiles directory."
  exit 1
fi

# Create config directories
print_status "Creating config directories..."
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/dunst
mkdir -p ~/.config/kitty
mkdir -p ~/.local/share/waybar/scripts

# Backup existing configs (if they exist)
if [ -f ~/.config/hypr/hyprland.conf ]; then
  print_warning "Backing up existing hyprland.conf..."
  cp ~/.config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf.backup.$(date +%Y%m%d_%H%M%S)
fi

if [ -f ~/.config/waybar/config ]; then
  print_warning "Backing up existing waybar config..."
  cp ~/.config/waybar/config ~/.config/waybar/config.backup.$(date +%Y%m%d_%H%M%S)
fi

# Copy configs
print_status "Copying Hyprland config..."
cp -f config/hypr/hyprland.conf ~/.config/hypr/

print_status "Copying Waybar config..."
cp -f config/waybar/config ~/.config/waybar/
if [ -f config/waybar/style.css ]; then
  cp -f config/waybar/style.css ~/.config/waybar/
fi

# Copy other common configs if they exist
if [ -f config/dunst/dunstrc ]; then
  print_status "Copying Dunst config..."
  mkdir -p ~/.config/dunst
  cp -f config/dunst/dunstrc ~/.config/dunst/
fi

if [ -f config/kitty/kitty.conf ]; then
  print_status "Copying Kitty config..."
  mkdir -p ~/.config/kitty
  cp -f config/kitty/kitty.conf ~/.config/kitty/
fi

# Install required packages (Arch Linux)
read -p "Do you want to install required packages? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  print_status "Installing required packages..."

  # Check if pacman is available (Arch Linux)
  if command -v pacman &>/dev/null; then
    sudo pacman -Sy --needed hyprland waybar wofi hyprpaper dunst \
      grim slurp wl-clipboard cliphist brightnessctl \
      playerctl pulseaudio pavucontrol networkmanager \
      wireless_tools alsa-utils bluez blueman \
      kitty thunar firefox
  elif command -v apt &>/dev/null; then
    # Debian/Ubuntu
    sudo apt update
    sudo apt install -y hyprland waybar wofi hyprpaper dunst \
      grim slurp wl-clipboard cliphist brightnessctl \
      playerctl pulseaudio pavucontrol network-manager \
      wireless-tools alsa-utils bluez blueman \
      kitty thunar firefox
  else
    print_warning "Unknown package manager. Please install packages manually."
  fi
fi

# Enable services
print_status "Enabling services..."
sudo systemctl enable bluetooth.service
sudo systemctl enable NetworkManager.service

# Create autostart directory if it doesn't exist
mkdir -p ~/.config/autostart

# Reload Hyprland if it's running
if pgrep Hyprland >/dev/null; then
  print_status "Reloading Hyprland..."
  hyprctl reload
else
  print_warning "Hyprland is not running. Start it manually or log in again."
fi

print_status "✅ Installation completed!"
print_status "💡 Restart your session or run 'hyprctl reload' to apply changes."

echo
echo "📋 What's included:"
echo "   • Hyprland configuration"
echo "   • Waybar with network module"
echo "   • Dunst notifications"
echo "   • Kitty terminal config"
echo "   • Optimized screenshot binds"
echo
echo "🔄 To reload Hyprland: hyprctl reload"
echo "🔄 To restart Waybar: pkill waybar && waybar"
