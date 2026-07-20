#!/bin/bash
echo "Content-type: text/plain"
echo ""

# check raw status
MPC_OUT=$(mpc current)
JST=$(TZ="Asia/Tokyo" date "+%Y%m%d%H%M%S")
CALCULATED_HOURS=$(/usr/lib/cgi-bin/calculate-30hours.sh)
RADIKO_DATE=${CALCULATED_HOURS:0:8}
LAST_PLAYED="/tmp/last_played"

LAST_PLAYED_RADIKO=$(cat /tmp/last_played_radiko)
RADIKO_XML="/tmp/${LAST_PLAYED_RADIKO}_${RADIKO_DATE}.xml"

# check if playing or not
if [ -n "$MPC_OUT" ]; then
    if [[ "$MPC_OUT" = *"localhost:8080"* ]]; then
        # get program info from XML
        if [ -f "$RADIKO_XML" ]; then
            xmllint --xpath "/radiko/stations/station/progs/prog[@ft <= ${JST} and ${JST} < @to]/title/text()" ${RADIKO_XML}
        elif [ -f "$LAST_PLAYED" ] && [ -e "$RADIKO_XML" ]; then
            cat "$LAST_PLAYED"
        else # fail safe
            echo "radiko 再生中"
        fi
    else
        # when streaming not started or song info not loaded
        if [[ "$MPC_OUT" == http* ]]; then # for RNE
            # get station name temporalily
            if [ -f "$LAST_PLAYED" ]; then
                cat "$LAST_PLAYED"
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
