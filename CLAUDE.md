# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Raspberry Pi-based barcode label printing application designed for warehouses and logistics operations. It integrates with Zebra ZPL thermal label printers via CUPS, fetches product data from XML feeds, and provides a PyQt5 GUI for scanning and printing barcode labels.

## System Architecture

### Core Components

1. **YesBarcode.py** - Main PyQt5 GUI application
   - Handles barcode scanning input (keyboard/barcode scanner)
   - Fetches and parses XML product data feeds
   - Generates ZPL commands for label printing
   - Manages printer queue selection and settings
   - Supports two label types: product barcodes (SKU/EAN) and QR location codes

2. **Zebra Module** - Custom printer interface (`zebra.py`)
   - Cross-platform wrapper for sending ZPL commands to printers
   - Uses `lpr` on Linux, `win32print` on Windows
   - Communicates with CUPS printer queues

3. **Printer Setup** - CUPS integration (`setup_zebra_printer.sh`)
   - Configures Zebra printers via CUPS with PPD files or RAW driver
   - Supports two label sizes: 57x32mm (barcode) and 150x102mm (shipping)
   - Creates printer queues: `ZebraBarcode` and `ZebraShipping`

4. **PrintNode Integration** - Remote printing capability
   - Allows remote print job submission
   - Runs as systemd service in headless mode

### Data Flow

1. XML feed downloaded hourly and cached to `/home/pi/barcode-pi/barcode-label-data.xml`
2. Feed parsed into dictionaries mapping SKU↔EAN↔ProductName
3. User scans barcode (SKU <12 chars or EAN ≥12 chars)
4. App looks up product data and generates ZPL label command
5. ZPL sent to selected printer queue via zebra module
6. Label printed on thermal printer

### Label Types

**Product Barcode Labels** (detected by input length):
- SKU (<12 chars) or EAN (≥12 chars)
- Displays: product name, barcode, SKU-EAN composite

**QR Location Labels** (detected by pattern):
- Input format: `X-X-X-X` (4 segments separated by dashes)
- Generates QR code + large container number
- Used for warehouse location tracking

## Development Environment Setup

### Prerequisites (Raspberry Pi OS)

```bash
# System dependencies installed by install_barcode_app.sh:
sudo apt-get install \
    cups cups-bsd cups-client \
    python3 python3-pip python3-venv \
    python3-pyqt5 python3-pyqt5.qtsvg pyqt5-dev-tools \
    libcups2-dev python3-cups \
    fonts-freefont-ttf
```

### Application Setup

```bash
# Clone and navigate
cd /home/pi/barcode-pi

# Virtual environment is at /home/pi/barcode_env
source ~/barcode_env/bin/activate

# The zebra module is created during installation at:
# /home/pi/barcode_env/lib/python3.11/site-packages/zebra.py
```

### Running the Application

```bash
# Manual run (generates UI code from .ui file first)
cd /home/pi/barcode-pi
source ~/barcode_env/bin/activate
pyuic5 -x neo_bar.ui -o neo_bar.py
python3 YesBarcode.py

# Or use the wrapper script
./run.sh

# Run with delayed start (for autostart)
./run-sleep.sh
```

### Development on Non-Pi Systems

The app uses platform detection (`if platform.system() == 'Linux'`) and can run on Windows/macOS for UI development, but printer functions require Linux + CUPS.

## Configuration Management

### Application Settings

Settings stored via `QSettings('1','1')`:
- `url` - XML feed URL
- `default_printer` - Selected CUPS printer queue name
- `autoprint` - Auto-print on barcode scan (bool)
- `copies` - Number of label copies (int)

Settings location: `~/.config/1/1.conf` (platform-dependent)

### Setting XML Feed URL

```bash
# Via command line
python3 /home/pi/barcode-pi/set_url.py "https://example.com/feed.xml"

# Via GUI
# Double-click the URL field to enable editing, modify, then click Save
```

## Printer Management

### Setup Zebra Printer

```bash
sudo ./setup_zebra_printer.sh
# Prompts for:
# 1. USB device selection
# 2. Label size (57x32mm barcode or 150x102mm shipping)
# 3. Configuration method (PPD file or RAW)
# Automatically prints test label
```

### Remove All Printers

```bash
sudo ./remove_printers.sh
```

### Verify Printer Status

```bash
# Check printer availability
python3 verify_printer.py

# Check CUPS status
lpstat -p ZebraBarcode
lpstat -p ZebraShipping

# Check CUPS service
sudo systemctl status cups
```

## ZPL Label Generation

The app generates ZPL (Zebra Programming Language) commands dynamically:

**Barcode Label Format:**
- Product name (wrapped if >28 chars)
- EAN-13 or UPC barcode with appropriate symbology (`^BEN` or `^BUN`)
- SKU-EAN composite text at bottom

**QR Location Label Format:**
- Full code text
- QR code (`^BQN`)
- Large container number (last digit)

Key ZPL commands used:
- `^XA` / `^XZ` - Label start/end
- `^FO` - Field origin (positioning)
- `^A0` - Font selection
- `^BEN` / `^BUN` - EAN-13/UPC barcode
- `^BQN` - QR code
- `^BY` - Barcode settings

## Installation Menu System

The `menu.sh` script provides interactive installation:

1. **Install Barcode Application** - Main app setup
2. **Setup PrintNode** - Download and extract PrintNode client
3. **Setup PrintNode Service** - Configure systemd service
4. **Setup Zebra Printer** - CUPS printer configuration
5. **Remove Printers** - Clean printer setup
6. **Uninstall Everything** - Complete removal
7. **Exit**

### Quick Install (via curl)

```bash
curl -sSL https://raw.githubusercontent.com/Baanaaana/barcode-pi/main/install_menu.sh | sudo bash
```

## Services

### Barcode Printer Service

```bash
# Systemd service: /etc/systemd/system/barcode-printer.service
sudo systemctl start barcode-printer.service
sudo systemctl stop barcode-printer.service
sudo systemctl status barcode-printer.service

# Runs as user 'pi' with DISPLAY=:0
# Executes /home/pi/barcode-pi/run.sh
```

### PrintNode Service

```bash
# Systemd service: /etc/systemd/system/printnode.service
sudo systemctl start printnode
sudo systemctl stop printnode
sudo systemctl restart printnode
sudo systemctl status printnode

# Service runs PrintNode in headless mode for remote printing
```

## Debian 13 (Trixie) Compatibility

### PrintNode ICU Library Issue

**Problem**: PrintNode 4.28.14 (built for Bookworm) requires ICU 72 libraries, but Trixie ships with ICU 75+. This causes the error:
```
ImportError: libicui18n.so.72: cannot open shared object file: No such file or directory
```

**Solution**: The updated `setup_printnode.sh` automatically detects Trixie and installs ICU 72 compatibility libraries from Bookworm.

### Manual Fix (if needed)

If PrintNode fails to start on Trixie:

```bash
# Check for missing ICU library
ldd /home/pi/printnode/PrintNode | grep libicu

# Install ICU 72 manually
cd /tmp
wget http://ftp.debian.org/debian/pool/main/i/icu/libicu72_72.1-3+deb12u1_arm64.deb
sudo dpkg -i libicu72_72.1-3+deb12u1_arm64.deb
sudo apt-get install -f  # Fix any dependency issues

# Verify installation
dpkg -l | grep libicu

# Test PrintNode launch
DISPLAY=:0 /home/pi/printnode/PrintNode 2>&1 | tee ~/printnode_test.log
```

### Verifying PrintNode Works

```bash
# Check library dependencies
ldd /home/pi/printnode/PrintNode | grep "not found"
# (should return nothing if all libraries present)

# Check ICU libraries installed
dpkg -l | grep libicu
# Should show both libicu72 (for PrintNode) and libicu75+ (for system)

# Test launch with error output
timeout 5s /home/pi/printnode/PrintNode 2>&1
# Look for ImportError or library errors
```

## XML Feed Format

Expected structure:
```xml
<root>
    <item>
        <sku>PRODUCT123</sku>
        <barcode>1234567890123</barcode>
        <productname>Product Name Here</productname>
    </item>
    ...
</root>
```

## Key File Locations

- Application: `/home/pi/barcode-pi/`
- Virtual environment: `/home/pi/barcode_env/`
- XML cache: `/home/pi/barcode-pi/barcode-label-data.xml`
- PrintNode: `/home/pi/printnode/`
- Desktop shortcuts: `~/Desktop/BarcodeApp.desktop`, `~/Desktop/PrintNode.desktop`
- Autostart: `~/.config/autostart/barcode_printer.desktop`
- PPD files: `/home/pi/barcode-pi/*.ppd`

## Troubleshooting

### Printer Issues
```bash
# Restart CUPS
sudo systemctl restart cups

# Check printer queues
lpstat -p

# Check USB devices
lpinfo -v | grep Zebra

# Test print raw ZPL
echo "^XA^FO50,50^ADN,36,20^FDTest^FS^XZ" | lp -d ZebraBarcode -o raw
```

### Application Issues
```bash
# Check service logs
sudo journalctl -u barcode-printer.service -f

# Verify XML feed
cat /home/pi/barcode-pi/barcode-label-data.xml

# Check Qt platform
export QT_QPA_PLATFORM=xcb
```

### Display Issues
```bash
# Ensure DISPLAY is set (required for GUI)
export DISPLAY=:0
export XAUTHORITY=/home/pi/.Xauthority
```

### PrintNode Issues on Trixie

```bash
# Error: libicui18n.so.72: cannot open shared object file
# Solution: Install ICU 72 compatibility library
sudo apt-get install -y wget
cd /tmp
wget http://ftp.debian.org/debian/pool/main/i/icu/libicu72_72.1-3+deb12u1_arm64.deb
sudo dpkg -i libicu72_72.1-3+deb12u1_arm64.deb

# Verify fix
ldd /home/pi/printnode/PrintNode | grep libicu
# Should show libicui18n.so.72 => /usr/lib/aarch64-linux-gnu/libicui18n.so.72

# Test launch
timeout 5s /home/pi/printnode/PrintNode 2>&1 | head -20
```

## Important Considerations

1. **UI Compilation**: The app auto-generates `neo_bar.py` from `neo_bar.ui` on every run via `pyuic5`
2. **Focus Management**: Input field auto-focuses after each scan for continuous operation
3. **Autoprint Logic**: Disabled when copies > 1 to prevent accidental multi-prints
4. **Barcode Detection**: Length-based (<12 = SKU, ≥12 = EAN) and pattern-based (X-X-X-X = QR)
5. **CUPS Configuration**: Disables network printer browsing to avoid conflicts with PrintNode
6. **Platform Detection**: Some imports (zebra module, win32print) are conditional on platform
7. **Debian Compatibility**: PrintNode requires ICU 72 on Trixie (auto-installed by `setup_printnode.sh`)
