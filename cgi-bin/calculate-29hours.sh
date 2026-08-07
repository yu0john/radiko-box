#!/bin/bash

# this script calculates hours for radiko XML
# because radiko XML contains programs from 5AM JST to 4:59AM JST following day. 

CURRENT_DATE=$(TZ="Asia/Tokyo" date "+%Y%m%d")
CURRENT_HOUR=$(TZ="Asia/Tokyo" date "+%H")
CURRENT_MIN_SEC=$(TZ="Asia/Tokyo" date "+%M%S")

if [ "${CURRENT_HOUR}" -lt 5 ]; then
    RADIKO_DATE=$(TZ="Asia/Tokyo" date -d yesterday "+%Y%m%d")
    RADIKO_HOUR=(${CURRENT_HOUR} + 24)
else
    RADIKO_DATE=${CURRENT_DATE}
    RADIKO_HOUR=${CURRENT_HOUR}
fi

echo "${RADIKO_DATE}${RADIKO_HOUR}${CURRENT_MIN_SEC}"