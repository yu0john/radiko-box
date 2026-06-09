#!/bin/bash
echo "Content-type: text/plain"
echo ""

# check raw status
MPC_OUT=$(mpc status)
# get first line
LINE1=$(echo "$MPC_OUT" | head -n 1)

# check if playing or not（playing is on 2nd line?）
if echo "$MPC_OUT" | grep -q "\[playing\]"; then
    if [[ $LINE1 == *"localhost:8080"* ]]; then
        # take out last_played when radiko
        if [ -f /tmp/last_played ]; then
            cat /tmp/last_played
        else # fail safe
            echo "Radiko 再生中"
        fi
    else
        # RNE or NHK
        # when streaming not started or song info not loaded
        if [[ $LINE1 == http* ]]; then
            # get station name temporalily
            if [ -f /tmp/last_played ]; then
                cat /tmp/last_played
            else
                echo "$LINE1"
            fi
        else
            # when song info correctly received
            echo "$LINE1"
        fi
    fi
else
    # show stopped if nothing playing
    echo "Stopped"
fi
