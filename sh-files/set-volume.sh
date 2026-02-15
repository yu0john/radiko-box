#!/bin/bash
echo "Content-type: text/plain"
echo ""

# set volume according to URL query
VOL=$(echo "$QUERY_STRING" | sed -n 's/^vol=\([0-9]*\)$/\1/p')

if [ -n "$VOL" ]; then
    mpc volume "$VOL" > /dev/null
    echo "Volume set to $VOL"
else
    # return message if value is invalid
    echo "Invalid volume"
fi
