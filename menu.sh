#!/bin/bash

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display the menu
display_menu() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}     Barcode-Pi Installation Menu      ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    echo -e "${GREEN}Please select an option:${NC}"
    echo
    echo "  1) Install Barcode Application"
    echo "  2) Setup PrintNode"
    echo "  3) Setup PrintNode Service"
    echo "  4) Setup Zebra Printer"
    echo "  5) Remove Printers"
    echo "  6) Uninstall Everything"
    echo "  7) Exit"
    echo
    echo -e "${YELLOW}----------------------------------------${NC}"
    echo -n "Enter your choice [1-7]: "
}

# Function to run a script with proper error handling
run_script() {
    local script_name="$1"
    local script_display_name="$2"
    
    # Determine the script path - check both locations
    local script_path=""
    if [ -f "/home/pi/barcode-pi/$script_name" ]; then
        script_path="/home/pi/barcode-pi/$script_name"
    elif [ -f "/home/pi/$script_name" ]; then
        script_path="/home/pi/$script_name"
    elif [ -f "./$script_name" ]; then
        script_path="./$script_name"
    fi
    
    echo
    echo -e "${BLUE}Running: ${script_display_name}${NC}"
    echo -e "${YELLOW}----------------------------------------${NC}"
    
    if [ -n "$script_path" ] && [ -f "$script_path" ]; then
        # Make sure the script is executable
        chmod +x "$script_path"
        
        # Run the script
        if bash "$script_path"; then
            echo
            echo -e "${GREEN}✓ ${script_display_name} completed successfully${NC}"
        else
            echo
            echo -e "${RED}✗ ${script_display_name} failed with error code $?${NC}"
        fi
    else
        echo -e "${RED}✗ Error: Script not found: $script_name${NC}"
        echo -e "${RED}  Searched in: /home/pi/barcode-pi/, /home/pi/, and current directory${NC}"
    fi
    
    echo
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read -r
}

# Main menu loop
while true; do
    display_menu
    read -r choice
    
    case $choice in
        1)
            run_script "install_barcode_app.sh" "Install Barcode Application"
            ;;
        2)
            run_script "setup_printnode.sh" "Setup PrintNode"
            ;;
        3)
            run_script "setup_printnode_service.sh" "Setup PrintNode Service"
            ;;
        4)
            run_script "setup_zebra_printer.sh" "Setup Zebra Printer"
            ;;
        5)
            run_script "remove_printers.sh" "Remove Printers"
            ;;
        6)
            run_script "uninstall_barcode_app.sh" "Uninstall Everything"
            # If uninstall was successful, exit the menu
            if [ $? -eq 0 ]; then
                exit 0
            fi
            ;;
        7)
            echo
            echo -e "${GREEN}Exiting installation menu. Goodbye!${NC}"
            echo
            exit 0
            ;;
        *)
            echo
            echo -e "${RED}Invalid option. Please select a number between 1 and 7.${NC}"
            echo -e "${YELLOW}Press Enter to continue...${NC}"
            read -r
            ;;
    esac
done