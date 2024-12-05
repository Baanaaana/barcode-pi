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

# Create systemd service for PrintNode
echo "Creating PrintNode service..."
cat > /etc/systemd/system/printnode.service << EOF
[Unit]
Description=PrintNode Client Service
After=network.target cups.service
Wants=cups.service

[Service]
Type=simple
User=pi
ExecStart=/home/pi/printnode/PrintNode --headless
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Enable and start PrintNode service
echo "Enabling and starting PrintNode service..."
systemctl daemon-reload
systemctl enable printnode.service
systemctl start printnode.service

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
echo "1. After this script finishes, navigate to the directory:"
echo "   cd ~/printnode"
echo "2. Run PrintNode:"
echo "   ./PrintNode"
echo "3. Sign in with your PrintNode credentials when prompted"
echo "4. You can also start PrintNode using the desktop shortcut"

echo "PrintNode setup complete!" 