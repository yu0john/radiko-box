#!/bin/bash

# This script regularly gets XML files from API radiko.jp/v3
# and save them in purpose of reference.

sleep 30

RADIKO_DATE=$(/usr/lib/cgi-bin/calculate-30hours.sh)
DATE=${RADIKO_DATE:0:8}
DIRECTORY="/tmp"

# get station ID from json file
STATIONS=$(jq -r ".[].id // empty" /var/www/html/stationList.json)

for STATION in ${STATIONS[@]}; do
    if [ -n "$STATION" ] && [ "$STATION" != "null" ]; then # remove empty name and "null" just in case
        echo "fetching ${STATION}_${DATE}.xml... to ${DIRECTORY}"
        curl -s "https://radiko.jp/v3/program/station/date/${DATE}/${STATION}.xml" > "${DIRECTORY}/${STATION}_${DATE}.xml"
    else
        echo "requested xml not found"
    fi

    sleep 1
done
