#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Configure CUPS to allow remote administration and disable network printer browsing
sed -i 's/Listen localhost:631/Port 631/' /etc/cups/cupsd.conf
sudo sed -i 's/Browsing Yes/Browsing No/' /etc/cups/cupsd.conf
sudo sed -i 's/Browsing On/Browsing Off/' /etc/cups/cupsd.conf
sudo sed -i 's/BrowseRemoteProtocols dnssd/BrowseRemoteProtocols none/' /etc/cups/cups-browsed.conf

echo "Removing all configured printers..."

# Get list of all printers and remove them
while IFS= read -r printer; do
    if [ ! -z "$printer" ]; then
        echo "Removing printer: $printer"
        lpadmin -x "$printer"
    fi
done < <(lpstat -p | cut -d' ' -f2)

echo "All printers have been removed"
echo "You can verify with: lpstat -p" 