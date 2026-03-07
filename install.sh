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

# enabling apps launch automatically
systemctl enable mpd
systemctl enable nginx
systemctl enable fcgiwrap

systemctl start mpd
systemctl start nginx
systemctl start fcgiwrap

# change local host name to "radio.local"
hostnamectl set-hostname radio
systemctl restart avahi-daemon


# placing files

# move shellscripts
cd "$SCRIPT_DIR"
mkdir /usr/lib/cgi-bin/
chmod +x ./sh-files/*
mv ./sh-files/* /usr/lib/cgi-bin/

cd "$SCRIPT_DIR"

# configuration

# add default audio output to mpd.conf
# first, check if there is already default_output
if ! grep -q "default_output" /etc/mpd.conf; then
cat << 'EOF' | sudo tee -a /etc/mpd.conf > /dev/null
audio_output {
    type        "alsa"
    name        "default_output"
    device      "default"
    mixer_type  "software"
}
EOF

else
  echo "mpd.conf already has default audio output. Skipping this configuration."
fi

# write LED blinking setting to rc.local
# check if already added or not
if ! grep -q "pwr_led/delay_on" /etc/rc.local; then
  # insert sentences before "exit 0"
  sed -i '/^exit 0/i # 2s/1s ON/OFF LED connected to GPIO24\necho 2000 > /sys/class/leds/pwr_led/delay_on\necho 1000 > /sys/class/leds/pwr_led/delay_off\n' /etc/rc.local

else
  echo "LED configuration already exists in rc.local. Skipping."
fi
# change to executable just in case
chmod +x /etc/rc.local


# nginx settings
# locate extra config file
mv ./config-files/cgi-bin.conf /etc/nginx/snippets/

# check if default file has "include" line for additional setting
if ! grep -q "include /etc/nginx/snippets/cgi-bin.conf;" /etc/nginx/sites-available/default; then
  # insert sentence just after server {
  sed -i '/^server {/a \    include /etc/nginx/snippets/cgi-bin.conf;' /etc/nginx/sites-available/default
else
  echo "Nginx is already linked to cgi-bin config."
fi
# review syntax and reload settings
sudo nginx -t && sudo systemctl reload nginx

# stopping a bothering system app
mkdir /etc/systemd/system/systemd-networkd-wait-online.service.d/
mv ./config-files/override.conf /etc/systemd/system/systemd-networkd-wait-online.service.d/

# python files for physical buttons
cd "$SCRIPT_DIR"
chmod +x ./config-files/*.py
mv ./*.py /usr/local/bin/
mv ./*.service /etc/systemd/system/
# load and enable services
systemctl daemon-reload
systemctl enable shutdown-button.service
systemctl enable volume-control.service
# services start automatically after reboot


# nginx files
mv ./* /var/www/html/


# LED light setting
echo 'dtoverlay=gpio-led,gpio=24,label=pwr_led,trigger=timer' | tee -a /boot/firmware/config.txt



