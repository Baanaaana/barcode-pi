#!/bin/bash

# Function to configure PrintNode credentials
configure_printnode_credentials() {
    echo "Configuring PrintNode credentials..."
    echo "Please enter your PrintNode credentials:"
    read -p "Email: " PRINTNODE_EMAIL
    read -s -p "Password: " PRINTNODE_PASSWORD
    echo ""
    
    # Attempt to authenticate using the PrintNode binary
    echo "Attempting to authenticate with PrintNode..."
    
    # Get the system hostname
    HOSTNAME=$(hostname)
    
    # Create a temporary config file for PrintNode
    su - pi -c "cd /home/pi/printnode && echo -e '${PRINTNODE_EMAIL}\n${PRINTNODE_PASSWORD}' | ./PrintNode --email '${PRINTNODE_EMAIL}' --password '${PRINTNODE_PASSWORD}' --computer-name '${HOSTNAME}' --headless 2>/dev/null &"
    
    # Give it a moment to authenticate
    sleep 3
    
    # Kill the process as we just needed to authenticate
    pkill -f PrintNode
    
    echo "PrintNode authentication configured."
    echo ""
}

# Function to configure label printer settings
configure_label_printer() {
    echo "Configuring label printer settings..."
    echo ""
    
    # Detect connected USB printers
    echo "Detecting connected printers..."
    PRINTERS=$(lpstat -p 2>/dev/null | grep -E "printer" | awk '{print $2}')
    
    if [ -z "$PRINTERS" ]; then
        echo "No printers detected. Please ensure your label printer is connected."
        return
    fi
    
    echo "Found the following printers:"
    echo "$PRINTERS"
    echo ""
    
    # Common label sizes for Zebra printers
    echo "Select a label size configuration:"
    echo "1) 4x6 inch shipping labels (102x152mm)"
    echo "2) 2.25x1.25 inch labels (57x32mm)"
    echo "3) Custom size"
    echo "4) Skip label configuration"
    
    read -p "Enter your choice (1-4): " LABEL_CHOICE
    
    case $LABEL_CHOICE in
        1)
            WIDTH="102mm"
            HEIGHT="152mm"
            LABEL_NAME="4x6_shipping"
            ;;
        2)
            WIDTH="57mm"
            HEIGHT="32mm"
            LABEL_NAME="2.25x1.25_tiny"
            ;;
        3)
            read -p "Enter label width in mm: " CUSTOM_WIDTH
            read -p "Enter label height in mm: " CUSTOM_HEIGHT
            WIDTH="${CUSTOM_WIDTH}mm"
            HEIGHT="${CUSTOM_HEIGHT}mm"
            LABEL_NAME="custom_${CUSTOM_WIDTH}x${CUSTOM_HEIGHT}"
            ;;
        4)
            echo "Skipping label configuration."
            return
            ;;
        *)
            echo "Invalid choice. Skipping label configuration."
            return
            ;;
    esac
    
    # Create PPD modification for each detected printer
    for PRINTER in $PRINTERS; do
        echo ""
        read -p "Configure $PRINTER with ${WIDTH} x ${HEIGHT} labels? (y/n): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Get the PPD file path for this printer
            PPD_PATH="/etc/cups/ppd/${PRINTER}.ppd"
            
            if [ -f "$PPD_PATH" ]; then
                echo "Configuring $PRINTER with label size ${WIDTH} x ${HEIGHT}..."
                
                # Create a custom page size definition if it doesn't exist
                if ! grep -q "PageSize ${LABEL_NAME}" "$PPD_PATH"; then
                    # Backup the original PPD
                    cp "$PPD_PATH" "${PPD_PATH}.backup"
                    
                    # Add custom page size (converting mm to points: 1mm = 2.834646 points)
                    WIDTH_PT=$(echo "$WIDTH" | sed 's/mm//' | awk '{printf "%.0f", $1 * 2.834646}')
                    HEIGHT_PT=$(echo "$HEIGHT" | sed 's/mm//' | awk '{printf "%.0f", $1 * 2.834646}')
                    
                    # Add the custom page size definition to PPD
                    cat >> "$PPD_PATH" << EOF

*% Custom Label Size Added by Barcode-Pi Setup
*PageSize ${LABEL_NAME}/Custom ${WIDTH}x${HEIGHT}: "<</PageSize[${WIDTH_PT} ${HEIGHT_PT}]/ImagingBBox null>>setpagedevice"
*PageRegion ${LABEL_NAME}/Custom ${WIDTH}x${HEIGHT}: "<</PageSize[${WIDTH_PT} ${HEIGHT_PT}]/ImagingBBox null>>setpagedevice"
*ImageableArea ${LABEL_NAME}/Custom ${WIDTH}x${HEIGHT}: "0 0 ${WIDTH_PT} ${HEIGHT_PT}"
*PaperDimension ${LABEL_NAME}/Custom ${WIDTH}x${HEIGHT}: "${WIDTH_PT} ${HEIGHT_PT}"
EOF
                    
                    # Set as default paper size
                    lpadmin -p "$PRINTER" -o media=${LABEL_NAME}
                    
                    echo "Label size configured for $PRINTER"
                else
                    echo "Label size ${LABEL_NAME} already configured for $PRINTER"
                fi
            else
                echo "PPD file not found for $PRINTER. Skipping..."
            fi
        fi
    done
    
    # Restart CUPS to apply changes
    echo ""
    echo "Restarting CUPS service to apply changes..."
    systemctl restart cups
    
    echo "Label printer configuration complete!"
    echo ""
}

echo "PrintNode Setup and Configuration"
echo "=================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Check if PrintNode is already installed
if [ -d "/home/pi/printnode" ] && [ -f "/home/pi/printnode/PrintNode" ]; then
    echo "PrintNode is already installed."
    echo ""
    echo "What would you like to do?"
    echo "1) Reconfigure PrintNode credentials"
    echo "2) Configure label printer settings"
    echo "3) Both (credentials and printer settings)"
    echo "4) Reinstall PrintNode completely"
    echo "5) Exit"
    echo ""
    read -p "Enter your choice (1-5): " MENU_CHOICE
    
    case $MENU_CHOICE in
        1)
            configure_printnode_credentials
            ;;
        2)
            configure_label_printer
            ;;
        3)
            configure_printnode_credentials
            configure_label_printer
            ;;
        4)
            echo "Reinstalling PrintNode..."
            rm -rf /home/pi/printnode
            # Continue with normal installation
            ;;
        5)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Exiting..."
            exit 1
            ;;
    esac
    
    # If we selected options 1-3, we're done
    if [ "$MENU_CHOICE" != "4" ]; then
        echo "Configuration complete!"
        exit 0
    fi
fi

echo "Setting up PrintNode..."

# Download PrintNode client
PRINTNODE_URL="https://dl.printnode.com/client/printnode/4.28.14/PrintNode-4.28.14-pi-bookworm-aarch64.tar.gz" # Published: 2025-04-23
if ! wget "$PRINTNODE_URL" -O printnode.tar.gz; then
    echo "Error: Failed to download PrintNode client"
    echo "Please check if the URL is accessible: $PRINTNODE_URL"
    exit 1
fi

# Extract and install the package
echo "Extracting PrintNode..."
tar xf printnode.tar.gz

# Get the extracted directory name and rename to simple 'printnode'
PRINTNODE_DIR=$(ls -d PrintNode-*)
rm -rf /home/pi/printnode
mv "$PRINTNODE_DIR" /home/pi/printnode
chown -R pi:pi /home/pi/printnode

# Clean up
rm printnode.tar.gz

# Create desktop shortcut for PrintNode
echo "Creating PrintNode desktop shortcut..."
cat > /home/pi/Desktop/PrintNode.desktop << EOF
[Desktop Entry]
Type=Application
Name=PrintNode
Exec=/home/pi/printnode/PrintNode
Icon=printer
Terminal=false
Categories=Utility;
Comment=PrintNode Remote Printing Client
EOF

# Set correct permissions for the shortcut
chmod +x /home/pi/Desktop/PrintNode.desktop
chown pi:pi /home/pi/Desktop/PrintNode.desktop

echo -e "\nPrintNode has been installed to: /home/pi/printnode"

# Offer to configure PrintNode credentials
echo ""
read -p "Would you like to configure PrintNode credentials now? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    configure_printnode_credentials
    
    # Offer to configure label printer settings
    echo ""
    read -p "Would you like to configure label printer settings? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        configure_label_printer
    fi
else
    echo ""
    read -p "Would you like to configure label printer settings? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        configure_label_printer
    fi
fi

echo "To complete PrintNode setup:"
echo "1. If you didn't configure credentials above, double-click the PrintNode icon on your desktop"
echo "2. Sign in with your PrintNode credentials (if not done above)"
echo "3. Configure your PrintNode settings as needed"
echo "4. Close PrintNode when configuration is complete"
echo "5. Run the following command to enable PrintNode service:"
echo "   sudo ./setup_printnode_service.sh"
echo "6. You can always start PrintNode GUI using the desktop shortcut"

echo "PrintNode setup complete!"