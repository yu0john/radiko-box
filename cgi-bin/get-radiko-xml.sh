#!/bin/bash

# This script regularly gets XML files from radiko.jp/v3
# and save them in purpose of reference.

DATE=`date '+%Y%m%d'`
DIRECTORY="/tmp/radiko-xml-cache"

# get station ID from json file
STATIONS=$(jq -r '.[].id // empty' /var/www/html/stationList.json)

for STATION in ${STATIONS[@]}; do
    if [ -n "$STATION" ] && [ "$STATION" != "null" ]; then # remove empty name and "null" just in case
        curl -s "https://radiko.jp/v3/program/station/date/${DATE}/${STATION}.xml" > ${DIRECTORY}/${STATION}_${DATE}.xml
    else
        echo "not radiko station"
    fi

    sleep 1
done
