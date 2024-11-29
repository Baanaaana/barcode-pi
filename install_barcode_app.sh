#!/bin/bash

# Make script exit on any error
set -e

echo "Starting installation of Barcode Printing Application..."

# Update system package list
echo "Updating package list..."
sudo apt-get update

# Install required system packages
echo "Installing system dependencies..."
sudo apt-get install -y \
    cups \
    python3 \
    python3-pip \
    python3-pyqt5 \
    python3-pyqt5.qtsvg \
    libcups2-dev \
    git \
    wget \
    fonts-freefont-ttf \
    python3-venv \
    python3-dev \
    build-essential \
    python3-wheel \
    python3-setuptools \
    python3-requests \
    python3-pil \
    python3-appdirs \
    python3-xmltodict \
    python3-cups \
    pyqt5-dev-tools \
    qttools5-dev-tools

# Remove old installation if exists
echo "Cleaning up old installation..."
sudo systemctl stop barcode-printer.service 2>/dev/null || true
sudo systemctl disable barcode-printer.service 2>/dev/null || true
sudo rm -f /etc/systemd/system/barcode-printer.service
sudo systemctl daemon-reload
rm -rf ~/barcode-pi
rm -rf ~/barcode_env
rm -f ~/Desktop/BarcodeApp.desktop
rm -f ~/.config/autostart/barcode_printer.desktop

# Create virtual environment
echo "Creating Python virtual environment..."
python3 -m venv ~/barcode_env --system-site-packages

# Activate virtual environment and install additional packages
echo "Installing additional Python packages..."
source ~/barcode_env/bin/activate
pip install python-barcode

# Create zebra module
echo "Creating zebra module..."
cat > ~/barcode_env/lib/python3.11/site-packages/zebra.py << EOL
import subprocess
import sys

class zebra(object):
    def __init__(self, queue=None):
        self.queue = queue

    def _output_unix(self, commands):
        if self.queue == 'zebra_python_unittest':
            p = subprocess.Popen(['cat','-'], stdin=subprocess.PIPE)
        else:
            p = subprocess.Popen(['lpr','-P{}'.format(self.queue),'-l'], stdin=subprocess.PIPE)
        p.communicate(commands)
        p.stdin.close()

    def output(self, commands):
        assert self.queue is not None
        if sys.version_info[0] == 3:
            if type(commands) != bytes:
                commands = str(commands).encode()
        else:
            commands = str(commands).encode()
        self._output_unix(commands)

    def getqueues(self):
        queues = []
        try:
            output = subprocess.check_output(['lpstat','-p'], universal_newlines=True)
        except subprocess.CalledProcessError:
            return []
        for line in output.split('\n'):
            if line.startswith('printer'):
                queues.append(line.split(' ')[1])
        return queues

    def setqueue(self, queue):
        self.queue = queue

    def setup(self, direct_thermal=None, label_height=None, label_width=None):
        commands = '\n'
        if direct_thermal:
            commands += ('OD\n')
        if label_height:
           commands += ('Q%s,%s\n'%(label_height[0],label_height[1]))
        if label_width:
            commands += ('q%s\n'%label_width)
        self.output(commands)
EOL

# Create application directory
echo "Creating application directory..."
rm -rf ~/barcode-pi
mkdir -p ~/barcode-pi
cd ~/barcode-pi

# Create printer setup files
echo "Creating printer setup files..."
cat > setup_zebra_printer.sh << 'EOL'
#!/bin/bash

echo "Setting up Zebra GK420D printer..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Install required packages
echo "Installing required packages..."
apt-get update
apt-get install -y cups cups-client python3-cups

# Restart CUPS service
systemctl restart cups

# Add pi user to lpadmin group for printer management
usermod -a -G lpadmin pi

# Stop CUPS service to modify configuration
systemctl stop cups

# Configure CUPS to allow remote administration
sed -i 's/Listen localhost:631/Port 631/' /etc/cups/cupsd.conf
sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf

# Add network access to CUPS
cat >> /etc/cups/cupsd.conf << EOF

# Allow remote access
<Location />
  Order allow,deny
  Allow @LOCAL
</Location>

<Location /admin>
  Order allow,deny
  Allow @LOCAL
</Location>

<Location /admin/conf>
  AuthType Default
  Require user @SYSTEM
  Order allow,deny
  Allow @LOCAL
</Location>
EOF

# Start CUPS service
systemctl start cups

# Wait for CUPS to fully start
sleep 5

# Add Zebra GK420D printer
echo "Adding Zebra GK420D printer..."
lpadmin -p ZebraGK420D \
    -E \
    -v usb://Zebra/GK420d \
    -m raw \
    -o printer-is-shared=true

# Set as default printer
lpoptions -d ZebraGK420D

# Configure default settings for 4x6 labels
lpoptions -p ZebraGK420D -o media=w4h6.0 -o resolution=203dpi

# Create test label
cat > /tmp/test_label.zpl << EOF
^XA
^FO50,50^BY3
^BCN,100,Y,N,N
^FD123456789^FS
^FO50,170^A0N,30,30
^FDTest Barcode^FS
^XZ
EOF

# Test print the barcode
echo "Printing test barcode..."
lp -d ZebraGK420D /tmp/test_label.zpl

# Update the barcode application configuration
if [ -f "/home/pi/barcode-pi/config.ini" ]; then
    echo "Updating barcode application configuration..."
    sed -i 's/^printer_name=.*/printer_name=ZebraGK420D/' /home/pi/barcode-pi/config.ini
else
    echo "Creating barcode application configuration..."
    cat > /home/pi/barcode-pi/config.ini << EOF
[Printer]
printer_name=ZebraGK420D
auto_print=true
copies=1
EOF
fi

# Set correct permissions for the config file
chown pi:pi /home/pi/barcode-pi/config.ini

echo "Printer setup complete!"
echo "Test barcode has been sent to the printer"
echo "The barcode application has been configured to use the Zebra GK420D printer"
echo "You can check printer status by running: lpstat -p ZebraGK420D"
EOL

cat > verify_printer.py << 'EOL'
#!/usr/bin/env python3
import cups
import sys

def verify_printer():
    conn = cups.Connection()
    printers = conn.getPrinters()
    
    zebra_printer = None
    for printer in printers:
        if printer == 'ZebraGK420D':
            zebra_printer = printer
            break
    
    if zebra_printer:
        print("✓ Zebra GK420D printer found and configured")
        print(f"Printer status: {printers[zebra_printer]['printer-state-message']}")
        return True
    else:
        print("✗ Zebra GK420D printer not found")
        print("Available printers:", list(printers.keys()))
        return False

if __name__ == "__main__":
    success = verify_printer()
    sys.exit(0 if success else 1)
EOL

# Make printer setup files executable
chmod +x setup_zebra_printer.sh
chmod +x verify_printer.py

# Download the application files from your repository
echo "Downloading application files..."
git clone https://github.com/Baanaaana/barcode-pi.git ./temp
cp -r ./temp/barcode-pi/* .
rm -rf ./temp

# Create printer setup instructions
echo "Creating printer setup instructions..."
cat > ~/barcode-pi/PRINTER_SETUP.txt << EOL
To set up your Zebra GK420D printer:

1. Connect the printer via USB to your Raspberry Pi
2. Run the setup script:
   sudo ./setup_zebra_printer.sh
3. Verify the printer setup:
   python3 verify_printer.py

A test barcode will be printed automatically during setup.
EOL

# Create printer configuration
echo "Creating printer configuration..."
cat > ~/barcode-pi/config.ini << EOF
[Printer]
printer_name=ZebraGK420D
auto_print=true
copies=1
EOF

# Create required directories and files
mkdir -p ~/.config/autostart

# Create desktop shortcut
cat > ~/Desktop/BarcodeApp.desktop << EOF
[Desktop Entry]
Type=Application
Name=Barcode App
Exec=/home/pi/barcode-pi/run.sh
Icon=applications-system
Terminal=false
Categories=Utility;
EOF

chmod +x ~/Desktop/BarcodeApp.desktop

# Create autostart entry
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/barcode_printer.desktop << EOF
[Desktop Entry]
Type=Application
Name=Barcode Printer
Exec=/home/pi/barcode-pi/run-sleep.sh
Terminal=false
EOF

# Set up systemd service
sudo bash -c 'cat > /etc/systemd/system/barcode-printer.service << EOF
[Unit]
Description=Barcode Printer Service
After=network.target

[Service]
ExecStart=/home/pi/barcode-pi/run.sh
User=pi
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/pi/.Xauthority

[Install]
WantedBy=multi-user.target
EOF'

# Enable and start the service
sudo systemctl enable barcode-printer.service
sudo systemctl start barcode-printer.service

# Set permissions
echo "Setting permissions..."
chmod +x ~/.config/autostart/barcode_printer.desktop
chmod +x ~/Desktop/BarcodeApp.desktop
chmod +x ~/barcode-pi/run.sh
chmod +x ~/barcode-pi/run-sleep.sh
chmod +x ~/barcode-pi/YesBarcode.py
chmod +x ~/barcode-pi/set_url.py
chmod +x ~/barcode-pi/setup_zebra_printer.sh
chmod +x ~/barcode-pi/verify_printer.py

echo "Installation complete!"
echo "The application will start automatically on next boot"
echo "You can also start it manually using the desktop shortcut" 