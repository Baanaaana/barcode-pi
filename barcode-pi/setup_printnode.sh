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

# Get the extracted directory name
PRINTNODE_DIR=$(ls -d PrintNode-*)

echo -e "\nPrintNode has been extracted to: $PRINTNODE_DIR"
echo "To complete PrintNode setup:"
echo "1. After this script finishes, navigate to the directory:"
echo "   cd ~/barcode-pi/$PRINTNODE_DIR"
echo "2. Run PrintNode:"
echo "   ./PrintNode"
echo "3. Sign in with your PrintNode credentials when prompted"

# Move PrintNode directory to the application directory for future use
mv "$PRINTNODE_DIR" ~/barcode-pi/
rm printnode.tar.gz

echo "PrintNode setup complete!" 