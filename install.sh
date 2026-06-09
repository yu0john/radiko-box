#!/bin/bash

########################################################################
# This is installation script.                                         #
# Installs software and places pre-configured files.                #
########################################################################

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

# install apps required
apt update
apt install -y mpc mpd ffmpeg nginx fcgiwrap avahi-daemon python3-rpi.gpio python3-pip
pip install --break-system-packages yt-dlp yt-dlp-rajiko
echo "apps installed"

# enable apps launch automatically
systemctl enable mpd nginx fcgiwrap avahi-daemon

# change local host name to "radio.local"
echo "setting hostname to radio..."
hostnamectl set-hostname radio

# placing files

# move shellscripts
cd "$SCRIPT_DIR"
echo "placing shellscripts..."
chmod +x ./cgi-bin/*
cp -r ./cgi-bin /usr/lib/

# let nginx reboot and shutdown
echo "give reboot and shutdown permission to nginx..."
SHUTDOWN_PATH=$(which shutdown)
REBOOT_PATH=$(which reboot)
echo "www-data ALL=(ALL) NOPASSWD: ${SHUTDOWN_PATH}, ${REBOOT_PATH}" | sudo tee /etc/sudoers.d/nginx-shutdown > /dev/null
chmod 0440 /etc/sudoers.d/nginx-shutdown

# copy configuration files
echo "copying config files..."

# mpd config
if [ -f /etc/mpd.conf ] && [ -f /etc/mpd.conf.bak ]; then
  cp /etc/mpd.conf /etc/mpd.conf.bak
fi
\cp -f ./config-files/mpd.conf /etc/

# LED blinking config
if [ -f /etc/rc.local ] && [ -f /etc/rc.local.bak ]; then 
  cp /etc/rc.local /etc/rc.local.bak
fi
\cp -f ./config-files/rc.local /etc/

# nginx settings
# locate extra config file
cp -f ./config-files/cgi-bin.conf /etc/nginx/snippets/

# link cgi-bin.conf to nginx
if [ -f /etc/nginx/sites-available/default ] && [ -f /etc/nginx/sites-available/default.bak ]; then 
  cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
fi
\cp -f ./config-files/default /etc/nginx/sites-available/default

echo "setting GPIO..."
# python files for physical buttons
cd "$SCRIPT_DIR"
chmod +x ./config-files/*.py
cp ./config-files/*.py /usr/local/bin/
cp ./config-files/*.service /etc/systemd/system/

# load and enable services
systemctl daemon-reload
systemctl enable shutdown-button.service volume-control.service
# services start automatically after reboot

# nginx files
cp ./statics/* /var/www/html/
cp -r ./img /var/www/html/
cp -r ./font /var/www/html/

# LED light setting
echo "dtoverlay=gpio-led,gpio=24,label=pwr_led,trigger=timer" | sudo tee -a /boot/firmware/config.txt > /dev/null

echo "Configuration finished. Please reboot system."


