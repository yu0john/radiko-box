#!/bin/bash

echo "Content-type: text/plain"
echo ""

mpc toggle > /dev/null 2>&1

mpc | grep -oP '\[\K[^\]]+'

