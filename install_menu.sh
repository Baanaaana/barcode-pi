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

# Clone the repository to a temp directory first
echo -e "${GREEN}Cloning Barcode-Pi repository...${NC}"
TEMP_DIR="/tmp/barcode-pi-temp"
rm -rf "$TEMP_DIR"

if git clone "$REPO_URL" "$TEMP_DIR"; then
    echo -e "${GREEN}✓ Repository cloned successfully${NC}"
    
    # Create the installation directory
    mkdir -p "$INSTALL_DIR"
    
    echo "Organizing files in $INSTALL_DIR..."
    
    # First, copy all root-level files (menu.sh, install scripts, README, etc.)
    for file in "$TEMP_DIR"/*; do
        if [ -f "$file" ]; then
            cp "$file" "$INSTALL_DIR/"
        fi
    done
    
    # Then copy the contents of the barcode-pi subdirectory (application files)
    if [ -d "$TEMP_DIR/barcode-pi" ]; then
        echo "Copying application files..."
        cp -r "$TEMP_DIR/barcode-pi"/* "$INSTALL_DIR/" 2>/dev/null || true
    fi
    
    # Clean up temp directory
    rm -rf "$TEMP_DIR"
    
    # Make sure there's no nested barcode-pi subdirectory
    if [ -d "$INSTALL_DIR/barcode-pi" ]; then
        echo "Removing nested subdirectory..."
        rm -rf "$INSTALL_DIR/barcode-pi"
    fi
    
    # Set correct ownership for pi user
    chown -R pi:pi "$INSTALL_DIR"
    
    echo -e "${GREEN}✓ All files organized in $INSTALL_DIR${NC}"
else
    echo -e "${RED}✗ Failed to clone repository${NC}"
    rm -rf "$TEMP_DIR"
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
echo -e "The Barcode-Pi repository has been cloned to: ${YELLOW}$INSTALL_DIR${NC}"
echo
echo -e "${BLUE}To start using the menu, run ONE of these commands:${NC}"
echo
echo -e "  1. Quick start (reload shell and open menu):"
echo -e "     ${YELLOW}source ~/.bashrc && printer${NC}"
echo
echo -e "  2. Just reload shell (to enable 'printer' command):"
echo -e "     ${YELLOW}source ~/.bashrc${NC}"
echo
echo -e "  3. Open menu directly without reload:"
echo -e "     ${YELLOW}sudo $INSTALL_DIR/menu.sh${NC}"
echo
echo -e "${GREEN}After reloading, you can always open the menu by typing: ${YELLOW}printer${NC}"