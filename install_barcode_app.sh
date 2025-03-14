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
    cups-bsd \
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

# Download the application files from your repository
echo "Downloading application files..."
git clone https://github.com/Baanaaana/barcode-pi.git ./temp
cp -r ./temp/barcode-pi/* .
rm -rf ./temp

# Display printer setup instructions
echo "To set up your Zebra ZPL printer:"
echo "1. Connect the printer via USB to your Raspberry Pi"
echo "2. Run the setup script: sudo ./setup_zebra_printer.sh"
echo "3. Verify the printer setup: python3 verify_printer.py"
echo "A test barcode will be printed automatically during setup."

# Create printer configuration
echo "Creating printer configuration..."
cat > ~/barcode-pi/config.ini << EOF
[Printer]
printer_name=ZebraZPL
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
Icon=/home/pi/barcode-pi/barcode.ico
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
Icon=/home/pi/barcode-pi/barcode.ico
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
chmod +x ~/barcode-pi/remove_printers.sh
chmod +x ~/barcode-pi/setup_printnode.sh
chmod +x ~/barcode-pi/setup_printnode_service.sh

echo "Installation complete!"
echo "The application will start automatically on next boot"
echo "You can also start it manually using the desktop shortcut" 