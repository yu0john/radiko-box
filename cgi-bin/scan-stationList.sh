# this script extracts radiko station ids written in the /var/www/html/stationList.json

STATIONS=$(jq -r ".[].id // empty" ./stationList.json)
echo ${STATIONS}
