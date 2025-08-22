#!/bin/bash

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${RED}========================================${NC}"
echo -e "${RED}     Barcode-Pi Uninstall Script       ${NC}"
echo -e "${RED}========================================${NC}"
echo

# Confirm uninstallation
echo -e "${YELLOW}WARNING: This will remove the entire Barcode-Pi installation!${NC}"
echo -e "${YELLOW}This includes:${NC}"
echo "  - The barcode-pi application directory"
echo "  - Desktop shortcuts"
echo "  - Autostart configuration"
echo "  - PrintNode installation"
echo "  - All printer configurations"
echo "  - The printer command alias"
echo "  - All installation scripts"
echo
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Uninstallation cancelled.${NC}"
    exit 0
fi

echo
echo -e "${BLUE}Starting uninstallation...${NC}"

# Stop PrintNode service if it exists
if systemctl list-units --full -all | grep -Fq "printnode.service"; then
    echo "Stopping PrintNode service..."
    sudo systemctl stop printnode
    sudo systemctl disable printnode
    sudo rm -f /etc/systemd/system/printnode.service
    sudo systemctl daemon-reload
fi

# Remove all printers
if command -v lpstat &> /dev/null; then
    echo "Removing all configured printers..."
    for printer in $(lpstat -p | awk '{print $2}'); do
        sudo lpadmin -x "$printer" 2>/dev/null
    done
fi

# Remove barcode-pi application directory
if [ -d "$HOME/barcode-pi" ]; then
    echo "Removing barcode-pi application directory..."
    rm -rf "$HOME/barcode-pi"
fi

# Remove PrintNode installation
if [ -d "$HOME/printnode" ]; then
    echo "Removing PrintNode installation..."
    rm -rf "$HOME/printnode"
fi

# Remove desktop shortcuts
echo "Removing desktop shortcuts..."
rm -f "$HOME/Desktop/BarcodeApp.desktop"
rm -f "$HOME/Desktop/PrintNode.desktop"

# Remove autostart configuration
echo "Removing autostart configuration..."
rm -f "$HOME/.config/autostart/barcode_printer.desktop"

# Remove printer alias from .bashrc
echo "Removing printer command alias..."
if [ -f "$HOME/.bashrc" ]; then
    # Create a backup just in case
    cp "$HOME/.bashrc" "$HOME/.bashrc.backup"
    # Remove the printer alias lines
    sed -i '/# Printer installation menu alias/d' "$HOME/.bashrc"
    sed -i '/alias printer=/d' "$HOME/.bashrc"
fi

# Remove installation scripts from home directory
echo "Removing installation scripts..."
rm -f "$HOME/install_menu.sh"
rm -f "$HOME/install_barcode_app.sh"
rm -f "$HOME/setup_printnode.sh"
rm -f "$HOME/setup_printnode_service.sh"
rm -f "$HOME/setup_zebra_printer.sh"
rm -f "$HOME/remove_printers.sh"

# Remove this uninstall script (must be last)
SCRIPT_PATH="$0"

echo
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Uninstallation Complete!             ${NC}"
echo -e "${GREEN}========================================${NC}"
echo
echo "The Barcode-Pi application and all its components have been removed."
echo "A backup of your .bashrc file was created at: ~/.bashrc.backup"
echo
echo -e "${YELLOW}Note: You may need to restart your terminal or run 'source ~/.bashrc'${NC}"
echo -e "${YELLOW}      to fully remove the 'printer' command.${NC}"

# Self-delete this script
rm -f "$SCRIPT_PATH"