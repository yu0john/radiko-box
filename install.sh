#!/bin/bash

#############################################################################
# This is installation script.                                              #
# Installs software used for the radbian and places pre-configured files.   #
#############################################################################

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
pip install -y --break-system-packages yt-dlp yt-dlp-rajiko

# enable apps launch automatically
systemctl enable mpd nginx fcgiwrap avahi-daemon

# change local host name to "radio.local"
hostnamectl set-hostname radio

# placing files

# move shellscripts
cd "$SCRIPT_DIR"
mkdir /usr/lib/cgi-bin/
chmod +x ./sh-files/*
cp ./sh-files/* /usr/lib/cgi-bin/

# copy configuration files

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
if [ -f /etc/nignx/sites-available/default ] && [ -f /etc/nignx/sites-available/default.bak ]; then 
  cp /etc/nignx/sites-available/default /etc/nignx/sites-available/default.bak
fi
\cp -f ./config-files/default /etc/nignx/sites-available/default

# stopping a bothering system app
mkdir /etc/systemd/system/systemd-networkd-wait-online.service.d/
cp ./config-files/override.conf /etc/systemd/system/systemd-networkd-wait-online.service.d/

# python files for physical buttons
cd "$SCRIPT_DIR"
chmod +x ./config-files/*.py
cp ./*.py /usr/local/bin/
cp ./*.service /etc/systemd/system/
# load and enable services
systemctl daemon-reload
systemctl enable shutdown-button.service
systemctl enable volume-control.service
# services start automatically after reboot


# nginx files
cp ./* /var/www/html/


# LED light setting
echo 'dtoverlay=gpio-led,gpio=24,label=pwr_led,trigger=timer' | tee -a /boot/firmware/config.txt

echo "Configuration completed. Reboot system."
sleep 2000
reboot

