#!/bin/bash
echo "Content-type: text/plain"
echo ""

RADIKO_ID=$(echo "$QUERY_STRING" | sed -n 's/^.*url=\([^&]*\).*$/\1/p' | sed "s/%/\\\\x/g" | xargs -0 printf "%b")

# check raw status
MPC_OUT=$(mpc current)
RADIKO_SCRIPT=$(./radiko-program-info.sh)
DATE=${date '+%Y%m%d'}
RADIKO_XML="/tmp/radiko-xml-cache/${1}_$DATE.xml"

# check if playing or not
if [ -n "$MPC_OUT" ]; then
    if [[ "$MPC_OUT" = *"localhost:8080"* ]]; then
        # get program info from XML
        if [ -f "$RADIKO_XML" ]; then
            
        elif [ -f /tmp/last_played ]; then
            cat /tmp/last_played
        else # fail safe
            echo "Radiko 再生中"
        fi
    else
        # when streaming not started or song info not loaded
        if [[ "$MPC_OUT" == http* ]]; then # for RNE
            # get station name temporalily
            if [ -f /tmp/last_played ]; then
                cat /tmp/last_played
            else
                echo "$MPC_OUT"
            fi
        else
            # when song info correctly received
            echo "$MPC_OUT"
        fi
    fi
else
    # show stopped if nothing playing
    echo "Stopped"
fi
