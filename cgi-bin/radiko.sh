#!/bin/bash

# kill previous processes
source /usr/lib/cgi-bin/stop.sh

echo "Starting Radiko... please wait for 5-10 seconds"

# remove url= from string
# ej.: url=LFR -> LFR)
NAME=$(echo "$QUERY_STRING" | sed -n 's/.*name=\([^&]*\).*/\1/p' | sed 's/%\([0-9A-F][0-9A-F]\)/\\x\1/g;s/+/ /g' | xargs -0 echo -e)
ICON=$(echo "$QUERY_STRING" | sed -n 's/.*icon=\([^&]*\).*/\1/p' | sed 's/%\([0-9A-F][0-9A-F]\)/\\x\1/g;s/+/ /g' | xargs -0 echo -e)
ID=$(echo "$QUERY_STRING" | sed -n 's/.*id=\([^&]*\).*/\1/p' | sed 's/%\([0-9A-F][0-9A-F]\)/\\x\1/g;s/+/ /g' | xargs -0 echo -e)

echo "Radiko: $NAME" > /tmp/last_played
echo "$ICON" > /tmp/last_played_icon

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
