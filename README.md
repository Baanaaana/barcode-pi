# Barcode Label Printer for Raspberry Pi

A Python-based application for printing barcode labels using a Zebra ZPL printer on Raspberry Pi. The application fetches product data from an XML feed and allows for easy barcode label printing.

## Features
- Compatible with Zebra ZPL label printer
- XML feed integration for product data
- PrintNode integration for remote printing capabilities
- User-friendly GUI interface
- Automatic startup on boot
- Desktop shortcut for manual launch
- Auto-print functionality
- Multiple copies support

## Requirements
- Raspberry Pi (tested on Raspberry Pi OS)
- Zebra ZPL label printer
- Internet connection for XML feed
- Display for GUI interface
- PrintNode account (for remote printing)

## Quick Installation
Install the application with a single command:
```bash
curl -sSL https://raw.githubusercontent.com/Baanaaana/barcode-pi/main/install_barcode_app.sh | bash
```

This will:
- Install all required dependencies
- Set up the printer configuration
- Create desktop shortcuts
- Configure autostart at boot
- Set up the application environment
- Install PrintNode client

## Post-Installation
After installation:
1. The application will start automatically after system boot
2. You can find a desktop shortcut to launch the app manually
3. Configure your XML feed URL in the application interface or via SSH
4. Select your Zebra printer from the dropdown menu

## Configuration
The application can be configured through the GUI:
- XML Feed URL
- Printer selection
- Auto-print toggle
- Number of copies

## XML Feed URL
To set the XML feed URL via SSH:
```bash
python3 /home/pi/barcode-pi/set_url.py "XML_FEED_URL"
```

## Printer Setup
The system includes support for Zebra ZPL label printers. To set up the printers:

1. Connect the Zebra ZPL printers to your Raspberry Pi via USB.

2. Run the printer setup script:
```bash
cd ~/barcode-pi && sudo ./setup_zebra_printer.sh
```

3. During the setup, you will be prompted to:
   - Select the label size for each printer: 57x32mm (barcode label) or 150x102mm (shipping label).
   - Choose which USB-connected printer to configure for each label size.

4. A test barcode will be printed automatically during setup to confirm everything is working correctly.

Note: The printer is configured to use the raw printer driver, which allows direct ZPL commands to be sent to the printer. This is the recommended setup for Zebra label printers on Linux systems.

### Reset Printer Configuration
To remove all configured printers and start fresh:

```bash
cd ~/barcode-pi && sudo ./remove_printers.sh
```

This will:
- Remove all printers from CUPS
- Show you the current printer list (should be empty)
- Allow you to reconfigure them from scratch

## PrintNode Setup
The application includes PrintNode for remote printing capabilities. To set up PrintNode:

1. Install PrintNode (if not already installed):
```bash
cd ~/barcode-pi && sudo ./setup_printnode.sh
```

2. Double-click the PrintNode icon on your desktop

3. Sign in with your PrintNode credentials

4. Configure your PrintNode settings

5. Close PrintNode when configuration is complete

6. Enable the PrintNode service:
```bash
sudo ./setup_printnode_service.sh
```

To start/stop/restart the PrintNode service:
```bash
sudo systemctl start printnode    # Start the service
sudo systemctl stop printnode     # Stop the service
sudo systemctl restart printnode  # Restart the service
```

After setup, you can start PrintNode:
- You can always start PrintNode GUI using the desktop shortcut
- PrintNode will also start automatically at boot in headless mode

Note: You can get a PrintNode account from https://www.printnode.com/

To check PrintNode service status:
```bash
sudo systemctl status printnode
```

The printer setup script will automatically download and extract PrintNode. You'll need to complete the login step manually to ensure proper authentication.

## Uninstallation
To uninstall the Barcode Application and PrintNode:

```bash
# Stop and disable the Barcode Printer service
sudo systemctl stop barcode-printer.service && \
sudo systemctl disable barcode-printer.service && \
sudo rm -f /etc/systemd/system/barcode-printer.service && \
sudo systemctl daemon-reload

# Remove the Barcode Application files and virtual environment
rm -rf ~/barcode-pi && \
rm -rf ~/barcode_env && \
rm -f ~/Desktop/BarcodeApp.desktop && \
rm -f ~/.config/autostart/barcode_printer.desktop

# Stop and disable the PrintNode service
sudo systemctl stop printnode && \
sudo systemctl disable printnode && \
sudo rm -f /etc/systemd/system/printnode.service && \
sudo systemctl daemon-reload

# Remove the PrintNode directory
rm -f ~/Desktop/PrintNode.desktop && \
rm -rf /home/pi/printnode
```

## Troubleshooting
If you encounter any issues:
1. Ensure your Zebra printer is properly connected and powered on
2. Check that CUPS service is running (`sudo systemctl status cups`)
3. Verify your internet connection for XML feed access
4. Check application logs for errors
5. Verify PrintNode status (`systemctl status printnode-client`)

## Support
For issues and feature requests, please use the GitHub issues section.

The application will be installed to:
- Main application: `/home/pi/barcode-pi/`
- Virtual environment: `/home/pi/barcode_env/`
- Desktop shortcut: `~/Desktop/BarcodeApp.desktop`
- Autostart entry: `~/.config/autostart/barcode_printer.desktop`