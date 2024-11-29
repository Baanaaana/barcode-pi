#!/bin/bash
cd /home/pi/barcode-pi
source ~/barcode_env/bin/activate
export DISPLAY=:0
export PYTHONPATH=/home/pi/barcode-pi:/usr/lib/python3/dist-packages
export QT_QPA_PLATFORM=xcb
pyuic5 -x neo_bar.ui -o neo_bar.py
python3 YesBarcode.py