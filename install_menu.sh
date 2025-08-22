#!/bin/bash

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Barcode-Pi Menu Installer           ${NC}"
echo -e "${BLUE}========================================${NC}"
echo

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}Git is not installed. Installing git...${NC}"
    sudo apt-get update
    sudo apt-get install -y git
fi

# Repository URL and installation directory
REPO_URL="https://github.com/Baanaaana/barcode-pi.git"
INSTALL_DIR="/home/pi/barcode-pi"

# Remove old installation if it exists
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Removing old installation...${NC}"
    rm -rf "$INSTALL_DIR"
fi

# Clone the repository directly to /home/pi/barcode-pi
echo -e "${GREEN}Cloning Barcode-Pi repository...${NC}"
if git clone "$REPO_URL" "$INSTALL_DIR"; then
    echo -e "${GREEN}✓ Repository cloned successfully to $INSTALL_DIR${NC}"
    
    # Set correct ownership for pi user
    chown -R pi:pi "$INSTALL_DIR"
else
    echo -e "${RED}✗ Failed to clone repository${NC}"
    exit 1
fi

# Make all scripts executable
echo
echo "Setting up executable permissions..."
chmod +x "$INSTALL_DIR"/*.sh 2>/dev/null
chmod +x "$INSTALL_DIR"/barcode-pi/*.sh 2>/dev/null
chmod +x "$INSTALL_DIR"/barcode-pi/*.py 2>/dev/null

# Create symbolic links in home directory for easy access
echo "Creating shortcuts in home directory..."
scripts=(
    "menu.sh"
    "install_barcode_app.sh"
    "setup_printnode.sh"
    "setup_printnode_service.sh"
    "setup_zebra_printer.sh"
    "remove_printers.sh"
    "uninstall_barcode_app.sh"
)

for script in "${scripts[@]}"; do
    echo -n "  Creating shortcut for $script... "
    if [ -f "$INSTALL_DIR/$script" ]; then
        ln -sf "$INSTALL_DIR/$script" "/home/pi/$script"
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}⚠ Script not found${NC}"
    fi
done

# Setup printer command alias in .bashrc if not already present
echo
echo "Setting up 'printer' command..."
if ! grep -q "alias printer=" /home/pi/.bashrc 2>/dev/null; then
    echo "" >> /home/pi/.bashrc
    echo "# Printer installation menu alias" >> /home/pi/.bashrc
    echo "alias printer='sudo /home/pi/barcode-pi/menu.sh'" >> /home/pi/.bashrc
    echo -e "${GREEN}✓ 'printer' command has been added to your shell${NC}"
    echo -e "${YELLOW}Note: Run 'source ~/.bashrc' or open a new terminal to use the 'printer' command${NC}"
else
    echo -e "${GREEN}✓ 'printer' command already exists${NC}"
fi

echo
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}    Installation Complete!              ${NC}"
echo -e "${GREEN}========================================${NC}"
echo
echo "The Barcode-Pi repository has been cloned to: ${YELLOW}$INSTALL_DIR${NC}"
echo
echo "You can now:"
echo "  1. Run the menu directly: ${YELLOW}sudo $INSTALL_DIR/menu.sh${NC}"
echo "  2. Use the shortcut command: ${YELLOW}printer${NC} (after reloading your shell)"
echo "  3. Use shortcuts from home: ${YELLOW}sudo ~/menu.sh${NC}"
echo
echo -e "${BLUE}Starting the menu now...${NC}"
echo

# Start the menu
sudo "$INSTALL_DIR/menu.sh"