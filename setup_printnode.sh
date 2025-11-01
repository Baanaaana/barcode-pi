#!/bin/bash

echo "Setting up PrintNode..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Detect Debian version
DEBIAN_VERSION=$(cat /etc/debian_version | cut -d'.' -f1)
OS_CODENAME=$(grep VERSION_CODENAME /etc/os-release | cut -d'=' -f2)

echo "Detected OS: Debian $DEBIAN_VERSION ($OS_CODENAME)"


# Download PrintNode client
# PRINTNODE_URL="https://dl.printnode.com/client/printnode/4.28.14/PrintNode-4.28.14-pi-bookworm-aarch64.tar.gz" # Published: 2025-04-23
PRINTNODE_URL="https://dl.printnode.com/client/printnode/4.27.8/PrintNode-4.27.8-pi-bullseye-armv7l.tar.gz" 
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

# Install ICU 72 compatibility libraries for Debian 13 (Trixie)
if [ "$OS_CODENAME" = "trixie" ] || [ "$DEBIAN_VERSION" = "13" ]; then
    echo "Detected Debian Trixie - Installing ICU 72 compatibility libraries..."

    # Check if libicu72 is already installed
    if ! dpkg -l | grep -q "^ii  libicu72"; then
        echo "Downloading libicu72 package..."
        cd /tmp

        # Download libicu72 from Debian Bookworm repository
        ICU_URL="http://ftp.debian.org/debian/pool/main/i/icu/libicu72_72.1-3+deb12u1_arm64.deb"
        if ! wget "$ICU_URL" -O libicu72.deb; then
            echo "Error: Failed to download libicu72 package"
            echo "Please check your internet connection or try manually installing:"
            echo "  wget $ICU_URL"
            echo "  sudo dpkg -i libicu72_72.1-3+deb12u1_arm64.deb"
            exit 1
        fi

        # Install the package
        echo "Installing libicu72..."
        if ! dpkg -i libicu72.deb; then
            echo "Warning: dpkg installation had issues. Attempting to fix dependencies..."
            apt-get install -f -y
        fi

        # Clean up
        rm libicu72.deb

        echo "ICU 72 compatibility library installed successfully"
    else
        echo "ICU 72 already installed, skipping..."
    fi
fi

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

# Verify PrintNode can start (check for missing libraries)
echo -e "\nVerifying PrintNode installation..."
if ! ldd /home/pi/printnode/PrintNode | grep -q "not found"; then
    echo "✓ All required libraries are present"

    # Try a quick launch test (timeout after 3 seconds)
    echo "Testing PrintNode launch..."
    timeout 3s sudo -u pi /home/pi/printnode/PrintNode > /tmp/printnode_test.log 2>&1 &
    sleep 2
    if ps aux | grep -v grep | grep -q "PrintNode"; then
        echo "✓ PrintNode process started successfully"
        pkill -f PrintNode
    else
        # Check the error log
        if grep -q "libicu" /tmp/printnode_test.log; then
            echo "✗ Warning: ICU library issue detected"
            echo "  See /tmp/printnode_test.log for details"
            cat /tmp/printnode_test.log
        elif [ -s /tmp/printnode_test.log ]; then
            echo "✗ Warning: PrintNode had startup issues"
            echo "  See /tmp/printnode_test.log for details"
            head -20 /tmp/printnode_test.log
        else
            echo "✓ PrintNode launch test completed (GUI mode requires X session)"
        fi
    fi
else
    echo "✗ Warning: Missing libraries detected:"
    ldd /home/pi/printnode/PrintNode | grep "not found"
    echo "  PrintNode may not work correctly"
fi

echo -e "\nTo complete PrintNode setup:"
echo "1. Double-click the PrintNode icon on your desktop"
echo "2. Sign in with your PrintNode credentials"
echo "3. Configure your PrintNode settings"
echo "4. Close PrintNode when configuration is complete"
echo "5. Run the following command to enable PrintNode service:"
echo "   sudo ./setup_printnode_service.sh"
echo "6. You can always start PrintNode GUI using the desktop shortcut"

echo -e "\n✓ PrintNode setup complete!"