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
echo -e "${GREEN}✓ All scripts are now executable${NC}"

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
echo -e "${BLUE}To start using the menu, run ONE of these commands:${NC}"
echo
echo "  1. Quick start (reload shell and open menu):"
echo "     ${YELLOW}source ~/.bashrc && printer${NC}"
echo
echo "  2. Just reload shell (to enable 'printer' command):"
echo "     ${YELLOW}source ~/.bashrc${NC}"
echo
echo "  3. Open menu directly without reload:"
echo "     ${YELLOW}sudo $INSTALL_DIR/menu.sh${NC}"
echo
echo -e "${GREEN}After reloading, you can always open the menu by typing: ${YELLOW}printer${NC}"