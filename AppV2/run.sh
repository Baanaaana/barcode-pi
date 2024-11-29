#!/bin/bash
cd /home/pi/Desktop/AppV2
source ~/barcode_env/bin/activate
export DISPLAY=:0
export PYTHONPATH=/home/pi/Desktop/AppV2:/usr/lib/python3/dist-packages
export QT_QPA_PLATFORM=xcb
pyuic5 -x neo_bar.ui -o neo_bar.py
python3 YesBarcode.py