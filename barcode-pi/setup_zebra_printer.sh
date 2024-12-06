#!/bin/bash

echo "Setting up Zebra ZD220 printer..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Install required packages
echo "Installing required packages..."
apt-get update
apt-get install -y cups cups-client cups-bsd python3-cups

# Restart CUPS service
systemctl restart cups

# Add pi user to lpadmin group for printer management
usermod -a -G lpadmin pi

# Stop CUPS service to modify configuration
systemctl stop cups

# Configure CUPS to allow remote administration
sed -i 's/Listen localhost:631/Port 631/' /etc/cups/cupsd.conf
sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf

# Add network access to CUPS
cat >> /etc/cups/cupsd.conf << EOF

# Allow remote access
<Location />
  Order allow,deny
  Allow @LOCAL
</Location>

<Location /admin>
  Order allow,deny
  Allow @LOCAL
</Location>

<Location /admin/conf>
  AuthType Default
  Require user @SYSTEM
  Order allow,deny
  Allow @LOCAL
</Location>
EOF

# Start CUPS service
systemctl start cups

# Wait for CUPS to fully start
sleep 5

# Detect USB printer
echo "Detecting Zebra printer..."
PRINTER_URI=""
while IFS= read -r line; do
    if [[ $line == *"Zebra"* ]]; then
        PRINTER_URI=$(echo "$line" | awk '{print $2}')
        break
    fi
done < <(lpinfo -v)

if [ -z "$PRINTER_URI" ]; then
    echo "Error: No Zebra printer detected via USB"
    echo "Available devices:"
    lpinfo -v
    exit 1
fi

echo "Found printer at: $PRINTER_URI"

# Add Zebra ZD220 printer with specific settings
echo "Adding Zebra ZD220 printer..."
lpadmin -p ZebraZD220 \
    -E \
    -v "$PRINTER_URI" \
    -P /home/pi/barcode-pi/zebra.ppd \
    -o printer-is-shared=true \
    -o printer-error-policy=abort-job \
    -o PageSize=Custom.57x32mm \
    -o Resolution=302dpi

# Set as default printer
lpoptions -d ZebraZD220

# Create test label
cat > /tmp/test_label.zpl << EOF
^XA
^MMT
^PW406
^LL0305
^LS0
^FO50,50^BY3
^BCN,100,Y,N,N
^FD123456789^FS
^FO50,170^A0N,30,30
^FDTest Barcode^FS
^PQ1
^XZ
EOF

# Test print the barcode
echo "Printing test barcode..."
lp -d ZebraZD220 -o raw /tmp/test_label.zpl

echo "Printer setup complete!"
echo "Test barcode has been sent to the printer"
echo "You can check printer status by running: lpstat -p ZebraZD220"