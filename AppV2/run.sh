#!/bin/bash
cd /home/pi/Desktop/AppV2
source ~/barcode_env/bin/activate
export DISPLAY=:0
export PYTHONPATH=/home/pi/Desktop/AppV2
python3 YesBarcode.py