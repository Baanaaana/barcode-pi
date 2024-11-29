# Barcode System Setup

# Barcode Label Printer for Raspberry Pi

A Python-based application for printing barcode labels using a Zebra ZD220 printer on Raspberry Pi. The application fetches product data from an XML feed and allows for easy barcode label printing.

## Features

- Compatible with Zebra ZD220 label printer
- XML feed integration for product data
- User-friendly GUI interface
- Automatic startup on boot
- Desktop shortcut for manual launch
- Auto-print functionality
- Multiple copies support


## Requirements

- Raspberry Pi (tested on Raspberry Pi OS)
- Zebra ZD220 label printer
- Internet connection for XML feed
- Display for GUI interface


## Quick Installation

Install the application with a single command:
```
curl -sSL https://raw.githubusercontent.com/Baanaaana/barcode-pi/main/install_barcode_app.sh | bash
```
This will:
- Install all required dependencies
- Set up the printer configuration
- Create desktop shortcuts
- Configure autostart at boot
- Set up the application environment


## Manual Installation

If you prefer to review the installation script first:

1. Download the installation script:
```
wget https://raw.githubusercontent.com/Baanaaana/barcode-pi/main/install_barcode_app.sh
```
2. Make it executable:
```
chmod +x install_barcode_app.sh
```
3. Run the script:
```
./install_barcode_app.sh
```


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


## XML Feed URL

To set the XML feed URL via SSH:

```
python3 /home/pi/barcode-pi/set_url.py "XML_FEED_URL"
```


## Printer Setup

The system includes support for the Zebra ZD220 label printer. To set up the printer:

1. Connect the Zebra ZD220 printer to your Raspberry Pi via USB

2. After installing the barcode application, navigate to the application directory:
   ```bash
   cd ~/barcode-pi
   ```

3. Run the printer setup script:
   ```bash
   sudo ./setup_zebra_printer.sh
   ```

4. Verify the printer setup:
   ```bash
   python3 verify_printer.py
   ```

A test barcode will be printed automatically during setup to confirm everything is working correctly.

Note: The printer is configured to use the raw printer driver, which allows direct ZPL commands to be sent to the printer. This is the recommended setup for Zebra label printers on Linux systems.

### Troubleshooting Printer Setup

If you encounter issues with the printer:

1. Ensure the printer is properly connected via USB and powered on
2. Check the USB connection:
   ```bash
   lsusb | grep Zebra
   ```
3. Verify CUPS is running:
   ```bash
   systemctl status cups
   ```
4. Check printer status:
   ```bash
   lpstat -p ZebraZD220
   ```


## Uninstallation

To uninstall the application:
```
sudo systemctl stop barcode-printer.service && \
sudo systemctl disable barcode-printer.service && \
sudo rm -f /etc/systemd/system/barcode-printer.service && \
sudo systemctl daemon-reload && \
rm -rf ~/barcode-pi && \
rm -rf ~/barcode_env && \
rm -f ~/Desktop/BarcodeApp.desktop && \
rm -f ~/.config/autostart/barcode_printer.desktop
```

## Troubleshooting

If you encounter any issues:
1. Ensure your Zebra printer is properly connected and powered on
2. Check that CUPS service is running ("sudo systemctl status cups")
3. Verify your internet connection for XML feed access
4. Check application logs for errors


## Support

For issues and feature requests, please use the GitHub issues section.

The application will be installed to:
- Main application: `/home/pi/barcode-pi/`
- Virtual environment: `/home/pi/barcode_env/`
- Desktop shortcut: `~/Desktop/BarcodeApp.desktop`
- Autostart entry: `~/.config/autostart/barcode_printer.desktop`
