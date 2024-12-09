#!/bin/bash

echo "Removing all configured printers..."

# Get list of all printers and remove them
while IFS= read -r printer; do
    if [ ! -z "$printer" ]; then
        echo "Removing printer: $printer"
        lpadmin -x "$printer"
    fi
done < <(lpstat -p | cut -d' ' -f2)

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

# Start CUPS service
systemctl start cups

# Wait for CUPS to fully start
sleep 5

configure_printer() {
    # Detect USB printers
    echo "Detecting USB printers..."
    PRINTERS=()
    while IFS= read -r line; do
        if [[ $line == *"Zebra"* ]]; then
            PRINTERS+=("$line")
        fi
    done < <(lpinfo -v)

    if [ ${#PRINTERS[@]} -eq 0 ]; then
        echo "Error: No Zebra printers detected via USB"
        echo "Available devices:"
        lpinfo -v
        exit 1
    fi

    echo "Available Zebra printers:"
    for i in "${!PRINTERS[@]}"; do
        echo "$i) ${PRINTERS[$i]}"
    done

    read -p "Select the printer to configure (0-${#PRINTERS[@]}): " PRINTER_INDEX
    PRINTER_URI=$(echo "${PRINTERS[$PRINTER_INDEX]}" | awk '{print $2}')

    # Ask for label size
    echo "Select label size for configuration:"
    echo "1) 57x32mm (barcode label)"
    echo "2) 150x102mm (shipping label)"
    read -p "Enter choice (1 or 2): " LABEL_CHOICE

    if [ "$LABEL_CHOICE" -eq 1 ]; then
        PPD_FILE="/home/pi/barcode-pi/zebra-barcode.ppd"
        PAGE_SIZE="w57h32"
        PRINTER_NAME="ZebraBarcode"
    elif [ "$LABEL_CHOICE" -eq 2 ]; then
        PPD_FILE="/home/pi/barcode-pi/zebra-shipping.ppd"
        PAGE_SIZE="w150h102"
        PRINTER_NAME="ZebraShipping"
    else
        echo "Invalid choice. Exiting."
        exit 1
    fi

    # Add Zebra printer with specific settings
    echo "Adding $PRINTER_NAME printer..."
    lpadmin -p "$PRINTER_NAME" \
        -E \
        -v "$PRINTER_URI" \
        -P "$PPD_FILE" \
        -o printer-is-shared=true \
        -o printer-error-policy=abort-job \
        -o PageSize="$PAGE_SIZE" \
        -o Resolution=203dpi

    # Set as default printer
    lpoptions -d "$PRINTER_NAME"

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
    lp -d "$PRINTER_NAME" -o raw /tmp/test_label.zpl

    echo "Printer setup complete!"
    echo "Test barcode has been sent to the printer"
    echo "You can check printer status by running: lpstat -p $PRINTER_NAME"
}

while true; do
    configure_printer
    read -p "Do you want to configure another printer? (y/n): " CONTINUE
    if [[ "$CONTINUE" != "y" ]]; then
        break
    fi
done

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