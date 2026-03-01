#!/bin/bash

# root check
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root."
  echo "Try: sudo ./install.sh"
  exit 1
fi

# stop shellscript if an error happens
set -e

# get directory and store the value to variable
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# This is installation script.
# Installs software used for the radbian and places pre-configured files.

# install app required
apt install mpc mpd ffmpeg nginx fcgiwrap avahi-daemon python3-rpi.gpio python3-pip
pip install --break-system-packages yt-dlp yt-dlp-rajiko

# enabling apps launch automatically
systemctl enable mpd
systemctl enable nginx
systemctl enable fcgiwrap

systemctl start mpd
systemctl start nginx
systemctl start fcgiwrap

# change local host name to radio.local
hostnamectl set-hostname radio
systemctl restart avahi-daemon


# placing files below
# move shellscripts
cd "$SCRIPT_DIR"
mkdir /usr/lib/cgi-bin/
chmod +x ./sh-files/*
mv ./sh-files/* /usr/lib/cgi-bin/
rm -r ./sh-files

# configuration files
cd "$SCRIPT_DIR"
mv mpd.conf /etc/
mv rc.local /etc/
mv default /etc/nginx/sites-available/
mkdir /etc/systemd/system/systemd-networkd-wait-online.service.d/
mv override.conf /etc/systemd/system/systemd-networkd-wait-online.service.d/
mv ./*.py /usr/local/bin/
mv ./*.service /etc/systemd/system/
cd "$SCRIPT_DIR"
rm -r ./config-files

mv ./* /var/www/html/


# LED light setting
echo 'dtoverlay=gpio-led,gpio=24,label=pwr_led,trigger=timer' | tee -a /boot/firmware/config.txt



