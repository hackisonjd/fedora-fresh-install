#!/bin/bash
# This script is meant to be run after a fresh install of Fedora 41 as root. If any of these commands change with a new release, I'll edit this script.

# elevate to root if not already
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

VSCODE="[vscode]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc"

# Adds parameters to dnf config file.
echo "Adding special parameters to dnfconf..."
sleep 1
LINE="fastestmirror=True
max_parallel_downloads=5
defaultyes=True"
FILE="/etc/dnf/dnf.conf"
if grep -qF -- "$LINE" "$FILE"; then
    echo "dnf.conf already has the special parameters. Skipping..."
else
    echo -e "$LINE" >> "$FILE"
fi

# Clears cache, then installs updated packages.

echo "Installing updates..."
sudo dnf clean all
sudo dnf update

# Installs RPM Fusion repositories.
echo "Installing RPM Fusion repositories..."
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf group upgrade core

# Installs Flatpak and Flathub.
if [ -x "$(command -v flatpak)" ]; then
    echo "Flatpak is already installed. Skipping..."
else
    echo "Installing Flatpak repositories..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Set your hostname.
echo "Your hostname is currently set to: $(hostname), would you like to change it? (y/n)"
read ANSWER
if [ "$ANSWER" = "y" ]; then
    echo "Enter the hostname you want to use:"
    read HOSTNAME
    echo "Setting hostname..."
    sudo hostnamectl set-hostname $HOSTNAME
else
    echo "Skipping hostname change..."
fi

# Optionall add VSCode repository
echo "Would you like to add the VSCode repository to your system? (y/n)"
read ANSWER
if [ "$ANSWER" = "y" ]; then
    echo "Adding VSCode repository..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "$VSCODE" > /etc/yum.repos.d/vscode.repo
fi

# Installs Media Codecs.
echo "Installing Media Codecs..."
sudo dnf group install multimedia
