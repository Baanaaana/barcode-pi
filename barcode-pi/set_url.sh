#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: ./set_url.sh <feed_url>"
    exit 1
fi

source ~/barcode_env/bin/activate
python3 /home/pi/barcode-pi/set_url.py "$1" 