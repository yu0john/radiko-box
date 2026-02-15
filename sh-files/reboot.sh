#!/bin/sh

echo "Content-type: text/plain"
echo ""

(sleep 3; sudo reboot > /dev/null 2>&1) &
