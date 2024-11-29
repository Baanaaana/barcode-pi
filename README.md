# Barcode Label Printer for Raspberry Pi

A Python-based application for printing barcode labels using a Zebra GK420D printer on Raspberry Pi. The application fetches product data from an XML feed and allows for easy barcode label printing.

## Features

- Compatible with Zebra GK420D label printer
- XML feed integration for product data
- User-friendly GUI interface
- Automatic startup on boot
- Desktop shortcut for manual launch
- Auto-print functionality
- Multiple copies support

## Requirements

- Raspberry Pi (tested on Raspberry Pi OS)
- Zebra GK420D label printer
- Internet connection for XML feed
- Display for GUI interface

## Quick Installation

Install the application with a single command:

curl -sSL https://raw.githubusercontent.com/Baanaaana/barcode-pi/main/install_barcode_app.sh | bash

This will:
- Install all required dependencies
- Set up the printer configuration
- Create desktop shortcuts
- Configure autostart at boot
- Set up the application environment

## Manual Installation

If you prefer to review the installation script first:

1. Download the installation script:

wget https://raw.githubusercontent.com/Baanaaana/barcode-pi/main/install_barcode_app.sh

2. Make it executable:

chmod +x install_barcode_app.sh

3. Run the script:

./install_barcode_app.sh

## Post-Installation

After installation:
1. The application will start automatically after system boot
2. You can find a desktop shortcut to launch the app manually
3. Configure your XML feed URL in the application interface
4. Select your Zebra printer from the dropdown menu

## Configuration

The application can be configured through the GUI:
- XML Feed URL
- Printer selection
- Auto-print toggle
- Number of copies

## Troubleshooting

If you encounter any issues:
1. Ensure your Zebra printer is properly connected and powered on
2. Check that CUPS service is running ("sudo systemctl status cups")
3. Verify your internet connection for XML feed access
4. Check application logs for errors

## Support

For issues and feature requests, please use the GitHub issues section.
