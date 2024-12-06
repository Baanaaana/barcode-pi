#!/bin/bash

echo "Removing all configured printers..."

# Get list of all printers and remove them
while IFS= read -r printer; do
    if [ ! -z "$printer" ]; then
        echo "Removing printer: $printer"
        lpadmin -x "$printer"
    fi
done < <(lpstat -p | cut -d' ' -f2)

echo "Setting up Zebra ZPL printer..."

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

# Configure CUPS to allow remote administration and disable network printer browsing
sed -i 's/Listen localhost:631/Port 631/' /etc/cups/cupsd.conf
sudo sed -i 's/Browsing Yes/Browsing No/' /etc/cups/cupsd.conf
sudo sed -i 's/Browsing On/Browsing Off/' /etc/cups/cupsd.conf
sudo sed -i 's/BrowseRemoteProtocols dnssd/BrowseRemoteProtocols none/' /etc/cups/cups-browsed.conf

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

# Add Zebra ZPL printer with specific settings
echo "Adding Zebra ZPL printer..."
lpadmin -p ZebraZPL \
    -E \
    -v "$PRINTER_URI" \
    -P /home/pi/barcode-pi/zebra.ppd \
    -o printer-is-shared=true \
    -o printer-error-policy=abort-job \
    -o PageSize=w162h90 \
    -o Resolution=203dpi

# Set as default printer
lpoptions -d ZebraZPL

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
lp -d ZebraZPL -o raw /tmp/test_label.zpl

echo "Printer setup complete!"
echo "Test barcode has been sent to the printer"
echo "You can check printer status by running: lpstat -p ZebraZPL"
echo ""
echo "Setup complete! System will reboot in 10 seconds..."
echo "Press Ctrl+C to cancel reboot"
echo ""

# Countdown
for i in {10..1}
do
    echo -ne "\rRebooting in $i seconds... "
    sleep 1
done

echo -e "\rRebooting now...            "
sudo reboot