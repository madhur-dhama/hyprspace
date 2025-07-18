#!/bin/bash

# Print the logo
print_logo() {
    cat << "EOF"


██   ██ ██    ██ ██████  ██████  ███████ ██████   █████   ██████ ███████ 
██   ██  ██  ██  ██   ██ ██   ██ ██      ██   ██ ██   ██ ██      ██      
███████   ████   ██████  ██████  ███████ ██████  ███████ ██      █████   
██   ██    ██    ██      ██   ██      ██ ██      ██   ██ ██      ██      
██   ██    ██    ██      ██   ██ ███████ ██      ██   ██  ██████ ███████ 

                      Hyprland Wayland Environment Setup
                             by: madhur dhama                        


EOF
}


# Parse command line arguments
DEV_ONLY=false
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --dev-only) DEV_ONLY=true; shift ;;
    *) echo "Unknown parameter: $1"; exit 1 ;;
  esac
done

# Clear screen and show logo
clear
print_logo

# Exit on any error
set -e

# Source utility functions
source utils.sh

# Source the package list
if [ ! -f "packages.conf" ]; then
  echo "Error: packages.conf not found!"
  exit 1
fi

source packages.conf

if [[ "$DEV_ONLY" == true ]]; then
  echo "Starting development-only setup..."
else
  echo "Starting full system setup..."
fi

# Update the system first
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install yay AUR helper if not present
if ! command -v paru &> /dev/null; then
  echo "Installing paru AUR helper..."
  sudo pacman -S --needed git base-devel --noconfirm
  if [[ ! -d "paru" ]]; then
    echo "Cloning yay repository..."
  else
    echo "paru directory already exists, removing it..."
    rm -rf paru
  fi

  git clone https://aur.archlinux.org/paru.git

  cd paru
  echo "building paru"
  makepkg -si --noconfirm
  cd ..
  rm -rf paru
else
  echo "paru is already installed"
fi

# Install packages by category
if [[ "$DEV_ONLY" == true ]]; then
  # Only install essential development packages
  echo "Installing system utilities..."
  install_packages "${SYSTEM_UTILS[@]}"
  
  echo "Installing development tools..."
  install_packages "${DEV_TOOLS[@]}"
else
  # Install all packages
  echo "Installing system utilities..."
  install_packages "${SYSTEM_UTILS[@]}"
  
  echo "Installing development tools..."
  install_packages "${DEV_TOOLS[@]}"
  
  echo "Installing system maintenance tools..."
  install_packages "${MAINTENANCE[@]}"
  
  echo "Installing media packages..."
  install_packages "${MEDIA[@]}"
  
  echo "Installing fonts..."
  install_packages "${FONTS[@]}"
   
fi

echo "Setup complete! You may want to reboot your system."
