#!/bin/bash
echo "Content-type: text/plain"
echo ""

# get info from /tmp/last_played_icon
if [ -f /tmp/last_played_icon ]; then
    cat /tmp/last_played_icon
else
    # return string "default" when no icon info found
    echo "default"
fi
