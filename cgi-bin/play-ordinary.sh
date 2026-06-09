#!/bin/bash

# kill and stop radiko and MPD
source /usr/lib/cgi-bin/stop.sh

URL=$(echo "$QUERY_STRING" | sed -n 's/^.*url=\([^&]*\).*$/\1/p' | sed "s/%/\\\\x/g" | xargs -0 printf "%b")
NAME=$(echo "$QUERY_STRING" | sed -n 's/.*name=\([^&]*\).*/\1/p' | sed 's/%\([0-9A-F][0-9A-F]\)/\\x\1/g;s/+/ /g' | xargs -0 echo -e)
ICON=$(echo "$QUERY_STRING" | sed -n 's/.*icon=\([^&]*\).*/\1/p' | sed 's/%\([0-9A-F][0-9A-F]\)/\\x\1/g;s/+/ /g' | xargs -0 echo -e)

#echo "Stream: $URL" > /tmp/last_played
echo "$NAME" > /tmp/last_played
echo "$ICON" > /tmp/last_played_icon


mpc add "$URL"
sleep 2
mpc play


echo ""
echo "Started: $NAME"
