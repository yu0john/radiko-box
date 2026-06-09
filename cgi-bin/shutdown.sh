#!/bin/bash

echo "Content-type: text/plain"
echo ""

(sleep 3; sudo shutdown now > /dev/null 2>&1) &
