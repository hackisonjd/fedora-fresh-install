#!/bin/bash
# This script is meant to be run after a fresh install of Fedora 36 as root. If any of these commands change with a new release, I'll edit this script.

# Adds parameters to dnf config file.
echo "Adding special parameters to dnfconf..."
sleep 1
LINE="fastestmirror=True
max_parallel_downloads=10
defaultyes=True
keepcache=True"
FILE="test.txt"
if grep -qF -- "$LINE" "$FILE"; then
    echo "dnf.conf already has the special parameters. Skipping..."
else
    echo -e "$LINE" >> "$FILE"
fi

# Clears cache, then installs updated packages.

echo "Installing updates..."
sleep 1
sudo dnf clean all
sudo dnf update

# Installs RPM Fusion repositories.
echo "Installing RPM Fusion repositories..."
sleep 1
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf groupupdate core

# Installs Flatpak and Flathub.
echo "Installing Flatpak and Flathub...(GNOME AND KDE ONLY)"
sleep 1
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Set your hostname.
echo "Enter the hostname you want to use:"
read HOSTNAME
echo "Setting hostname..."
sleep 1
sudo hostnamectl set-hostname $HOSTNAME

# Installs Media Codecs.
echo "Installing Media Codecs..."
sleep 1
sudo dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf groupupdate sound-and-video

