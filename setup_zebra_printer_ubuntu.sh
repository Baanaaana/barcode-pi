#!/bin/bash

# Zebra Printer Setup Script for Ubuntu/Debian
# Works on x86_64, ARM64, and other architectures
# Compatible with Ubuntu, Debian, and Raspberry Pi OS

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Detect the user who invoked sudo (or current user if already root)
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(getent passwd "$ACTUAL_USER" | cut -d: -f6)

echo "Setting up Zebra printer for user: $ACTUAL_USER"
echo "Home directory: $ACTUAL_HOME"

# Detect script directory for PPD files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Script directory: $SCRIPT_DIR"

# Install required packages
echo "Installing required packages..."
apt-get update
apt-get install -y cups cups-client cups-bsd python3-cups

# Restart CUPS service
systemctl restart cups

# Add user to lpadmin group for printer management
echo "Adding $ACTUAL_USER to lpadmin group..."
usermod -a -G lpadmin "$ACTUAL_USER"

# Stop CUPS service to modify configuration
systemctl stop cups

# Configure CUPS to allow remote administration and disable network printer browsing
echo "Configuring CUPS..."
sed -i 's/Listen localhost:631/Port 631/' /etc/cups/cupsd.conf 2>/dev/null || true
sed -i 's/Browsing Yes/Browsing No/' /etc/cups/cupsd.conf 2>/dev/null || true
sed -i 's/Browsing On/Browsing Off/' /etc/cups/cupsd.conf 2>/dev/null || true
sed -i 's/BrowseRemoteProtocols dnssd/BrowseRemoteProtocols none/' /etc/cups/cups-browsed.conf 2>/dev/null || true

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

    read -p "Select the printer to configure (0-$((${#PRINTERS[@]}-1))): " PRINTER_INDEX
    PRINTER_URI=$(echo "${PRINTERS[$PRINTER_INDEX]}" | awk '{print $2}')

    # Ask for label size
    echo "Select label size for configuration:"
    echo "1) 57x32mm (barcode label)"
    echo "2) 150x102mm (shipping label)"
    read -p "Enter choice (1 or 2): " LABEL_CHOICE

    if [ "$LABEL_CHOICE" -eq 1 ]; then
        PAGE_SIZE="w162h90"
        PRINTER_NAME="ZebraBarcode"
        # Create test label for barcode printer
        cat > /tmp/test_label.zpl << 'EOF'
^XA
^LH0,25
^FO30,10^A0,30^FDZebra Barcode Printer^FS
^FO30,50^A0,30^FDSuccessfully Installed^FS
^FO30,90^BY3^BEN,60,N,N,N,N^FD123456789012^FS
^FO30,180^A0,30^FD123456 | 123456789123^FS
^XZ
EOF
    elif [ "$LABEL_CHOICE" -eq 2 ]; then
        PAGE_SIZE="w432h288"
        PRINTER_NAME="ZebraShipping"
        # Create test label for shipping printer
        cat > /tmp/test_label.zpl << 'EOF'
^XA
^FX
^CF0,60
^FO50,50^GB100,100,100^FS
^FO75,75^FR^GB100,100,100^FS
^FO93,93^GB40,40,40^FS
^FO220,50^FDZebraShipping Printer^FS
^FO220,120^FDSuccessfully Installed^FS
^CF0,30
^FO220,195^FDLabel size: 102x150mm^FS
^FO50,250^GB700,3,3^FS
^FX Second section with recipient address and permit information.
^CFA,30
^FO50,300^FDName^FS
^FO50,340^FDAddress^FS
^FO50,380^FDCity Postal code^FS
^FO50,420^FDCountry^FS
^CFA,15
^FO600,300^GB150,150,3^FS
^FO628,340^FDShipping^FS
^FO638,390^FD123456^FS
^FO50,500^GB700,3,3^FS
^FX Third section with bar code.
^BY5,3,270
^FO100,550^BC^FD12345678^FS
^FX Fourth section (the two boxes on the bottom).
^FO50,900^GB700,250,3^FS
^FO400,900^GB3,250,3^FS
^CF0,40
^FO100,960^FDORDER: 123456^FS
^FO100,1010^FDREF1:   123456^FS
^FO100,1060^FDREF2:   123456^FS
^CF0,190
^FO470,955^FDNL^FS
^XZ
EOF
    else
        echo "Invalid choice. Exiting."
        exit 1
    fi

    # Ask user if they want to use a PPD file or configure as RAW
    echo "Choose printer configuration method:"
    echo "1) Use PPD file (if available)"
    echo "2) Configure as RAW (recommended)"
    read -p "Enter choice (1 or 2): " CONFIG_CHOICE

    if [ "$CONFIG_CHOICE" -eq 1 ]; then
        # Look for PPD files in multiple locations
        PPD_FILE=""
        if [ "$LABEL_CHOICE" -eq 1 ]; then
            PPD_LOCATIONS=(
                "$SCRIPT_DIR/barcode-pi/zebra-barcode.ppd"
                "$SCRIPT_DIR/zebra-barcode.ppd"
                "$ACTUAL_HOME/barcode-pi/zebra-barcode.ppd"
                "/usr/share/ppd/zebra-barcode.ppd"
            )
        elif [ "$LABEL_CHOICE" -eq 2 ]; then
            PPD_LOCATIONS=(
                "$SCRIPT_DIR/barcode-pi/zebra-shipping.ppd"
                "$SCRIPT_DIR/zebra-shipping.ppd"
                "$ACTUAL_HOME/barcode-pi/zebra-shipping.ppd"
                "/usr/share/ppd/zebra-shipping.ppd"
            )
        fi

        # Try to find PPD file
        for loc in "${PPD_LOCATIONS[@]}"; do
            if [ -f "$loc" ]; then
                PPD_FILE="$loc"
                echo "Found PPD file at: $PPD_FILE"
                break
            fi
        done

        if [ -z "$PPD_FILE" ]; then
            echo "Warning: PPD file not found in standard locations."
            echo "Searched in:"
            for loc in "${PPD_LOCATIONS[@]}"; do
                echo "  - $loc"
            done
            read -p "Enter full path to PPD file (or press Enter to use RAW mode): " USER_PPD
            if [ -n "$USER_PPD" ] && [ -f "$USER_PPD" ]; then
                PPD_FILE="$USER_PPD"
            else
                echo "Falling back to RAW mode..."
                CONFIG_CHOICE=2
            fi
        fi

        if [ "$CONFIG_CHOICE" -eq 1 ]; then
            # Add Zebra printer with PPD file
            echo "Adding $PRINTER_NAME printer with PPD file..."
            lpadmin -p "$PRINTER_NAME" \
                -E \
                -v "$PRINTER_URI" \
                -P "$PPD_FILE" \
                -o printer-is-shared=true \
                -o printer-error-policy=abort-job \
                -o PageSize="$PAGE_SIZE" \
                -o Resolution=203dpi
        fi
    fi

    if [ "$CONFIG_CHOICE" -eq 2 ]; then
        # Add Zebra printer as RAW
        echo "Adding $PRINTER_NAME printer as RAW..."
        lpadmin -p "$PRINTER_NAME" \
            -E \
            -v "$PRINTER_URI" \
            -m raw \
            -o printer-is-shared=true \
            -o printer-error-policy=abort-job
    fi

    # Set as default printer
    lpoptions -d "$PRINTER_NAME"

    # Test print the barcode
    echo "Printing test label..."
    lp -d "$PRINTER_NAME" -o raw /tmp/test_label.zpl

    echo "Printer setup complete!"
    echo "Printer name: $PRINTER_NAME"
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
echo "✓ Setup complete!"
echo ""
echo "Configured printers:"
lpstat -p
echo ""
echo "Note: You may need to log out and back in for group membership changes to take effect."
