#!/bin/bash

# CGI header
echo "Content-type: text/plain"
echo ""

# stop ffmpeg and terminate yt-dlp
pkill -f "yt-dlp"
pkill -f "ffmpeg"

echo "Radiko process stopped"

# stop mpd player
mpc stop > /dev/null 2>&1
mpc clear > /dev/null 2>&1
echo "mpc playlist cleared"

# for mpc to insist playing stream
mpc repeat on > /dev/null 2>&1
mpc single on > /dev/null 2>&1

# clear last_played record
echo "" > /tmp/last_played
echo "Stopped" > /tmp/last_played_icon

# add more if needed

echo "Stop process completed"
