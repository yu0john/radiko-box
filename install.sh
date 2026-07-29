#!/bin/bash

########################################################################
# This is installation script.                                         #
# Installs software and places pre-configured files.                   #
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
apt install -y mpc mpd ffmpeg nginx fcgiwrap avahi-daemon python3-rpi.gpio python3-pip libxml2-utils
pip install --break-system-packages yt-dlp yt-dlp-rajiko

# enable apps launch automatically
systemctl enable mpd nginx fcgiwrap avahi-daemon

# change local host name to "radio.local"
echo "setting hostname to \"radio\"..."
hostnamectl set-hostname radio

# move shellscripts
cd "$SCRIPT_DIR"
echo "placing shellscripts..."
chmod a+x ./cgi-bin/*
cp -r ./cgi-bin /usr/lib/

# let nginx reboot and shutdown
echo "giving reboot and shutdown permissions to nginx..."
SHUTDOWN_PATH=$(which shutdown)
REBOOT_PATH=$(which reboot)
echo "www-data ALL=(ALL) NOPASSWD: ${SHUTDOWN_PATH}, ${REBOOT_PATH}" | sudo tee /etc/sudoers.d/nginx-shutdown > /dev/null
chmod 0440 /etc/sudoers.d/nginx-shutdown

# copy configuration files
echo "copying config files..."

# mpd config
if [ -f /etc/mpd.conf ] && [ ! -f /etc/mpd.conf.original ]; then
  mv /etc/mpd.conf /etc/mpd.conf.original
fi

if [ ! -f /etc/mpd.conf ]; then 
  cp ./config-files/mpd.conf /etc/mpd.conf
else
  echo "mpd.conf already exists. skipped overwriting."
fi

# LED blinking config
if [ -f /etc/rc.local ] && [ ! -f /etc/rc.local.original ]; then 
  mv /etc/rc.local /etc/rc.local.original
fi

if [ ! -f /etc/rc.local ]; then
  cp ./config-files/rc.local /etc/rc.local
else
  echo "rc.local already exists. skipped overwriting."
fi

# nginx settings
# locate extra config file
cp -n ./config-files/cgi-bin.conf /etc/nginx/snippets/cgi-bin.conf

# link cgi-bin.conf to nginx
if [ -f /etc/nginx/sites-available/default ] && [ ! -f /etc/nginx/sites-available/default.original ]; then 
  mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.original
fi

if [ ! -f /etc/nginx/sites-available/default ]; then
  cp ./config-files/default /etc/nginx/sites-available/default
else
  echo "sites-available/default already exists. skipped overwriting."
fi

# python files for physical buttons
cd "$SCRIPT_DIR"
chmod +x ./config-files/*.py
cp -n ./config-files/*.py /usr/local/bin/
cp -n ./config-files/*.service /etc/systemd/system/

# load and enable services
systemctl daemon-reload
systemctl enable shutdown-button.service volume-control.service

# nginx files
cp ./statics/* /var/www/html/
cp -r ./img /var/www/html/
cp -r ./font /var/www/html/

# LED light setting
echo "writing a line for LED light blinking..."
LED_LIGHTING="dtoverlay=gpio-led,gpio=24,label=pwr_led,trigger=timer"

if ! grep -qF "$LED_LIGHTING" /boot/firmware/config.txt; then
  echo "$LED_LIGHTING" | tee -a /boot/firmware/config.txt > /dev/null
else
  echo "default LED lighting setting already exists. skipped adding a line."
fi

# cron setting
echo "setting radiko XML downloading schedule..."
TEMPFILE="/tmp/radiko-box-cron-setting"
crontab -l 2>/dev/null | grep -Fv "/usr/lib/cgi-bin/get-radiko-xml.sh" \
  > "$TEMPFILE" || true

cat <<'EOF' >> "$TEMPFILE"
0 5 * * * CRON_TZ=Asia/Tokyo /usr/lib/cgi-bin/get-radiko-xml.sh >/dev/null 2>&1
@reboot /usr/lib/cgi-bin/get-radiko-xml.sh >/dev/null 2>&1
EOF

crontab "$TEMPFILE"
rm -f "$TEMPFILE"

echo "Configuration finished. Please reboot system."


