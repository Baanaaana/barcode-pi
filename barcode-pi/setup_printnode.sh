#!/bin/bash

echo "Setting up PrintNode..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Download PrintNode client
PRINTNODE_URL="https://dl.printnode.com/client/printnode/4.28.3/PrintNode-4.28.3-pi-bookworm-aarch64.tar.gz"
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
echo "To complete PrintNode setup:"
echo "1. Double-click the PrintNode icon on your desktop"
echo "2. Sign in with your PrintNode credentials"
echo "3. Configure your PrintNode settings"
echo "4. Close PrintNode when configuration is complete"
echo "5. Run the following command to enable PrintNode service:"
echo "   sudo ./setup_printnode_service.sh"
echo "6. You can always start PrintNode GUI using the desktop shortcut"

echo "PrintNode setup complete!" 