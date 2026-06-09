#!/bin/bash

echo "Content-type: text/plain"
echo ""

mpc volume | head -n 1 | grep -oP '\d+(?=%)'
