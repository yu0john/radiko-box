#!/bin/bash

# kill previous processes
source /usr/lib/cgi-bin/stop.sh

echo "Starting Radiko... please wait for 5-10 seconds"

# remove url= from string
# ej: url=LFR -> LFR)
ID=$(echo "$QUERY_STRING" | sed -n 's/^.*url=\([^&]*\).*$/\1/p')
echo "Radiko: $ID" > /tmp/last_played
echo "$ID" > /tmp/last_played_icon

(
       # start streaming as local HTTP with ffmpeg
       yt-dlp --no-cache-dir -o - "https://radiko.jp/#!/live/$ID" | \
       ffmpeg -re -i pipe:0 -c:a copy -f mpegts -listen 1 http://0.0.0.0:8080 > /dev/null 2>&1 &

       # need to wait until data received
       # adjust sleep length if no sound is heard
       mpc add http://localhost:8080
       mpc play

       sleep 5
       mpc play

       # just in case
       sleep 5
       mpc play

) > /dev/null 2>&1 &
