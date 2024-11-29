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
rm -rf ~/Desktop/AppV2
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

# Install CUPS driver for Zebra GK420D
echo "Setting up CUPS for Zebra printer..."
sudo usermod -a -G lpadmin $USER
sudo systemctl start cups
sudo systemctl enable cups

# Create application directory
echo "Creating application directory..."
mkdir -p ~/barcode-pi
cd ~/barcode-pi

# Download the application files from your repository
echo "Downloading application files..."
git clone https://github.com/Baanaaana/barcode-pi.git .

# Create required directories and files
mkdir -p ~/.config/autostart

# Update run scripts
echo "Updating run scripts..."
cat > ~/barcode-pi/run.sh << EOL
#!/bin/bash
cd /home/pi/barcode-pi
source ~/barcode_env/bin/activate
export DISPLAY=:0
export PYTHONPATH=/home/pi/barcode-pi:/usr/lib/python3/dist-packages
export QT_QPA_PLATFORM=xcb
pyuic5 -x neo_bar.ui -o neo_bar.py
python3 YesBarcode.py
EOL

cat > ~/barcode-pi/run-sleep.sh << EOL
#!/bin/bash
sleep 10
cd /home/pi/barcode-pi
source ~/barcode_env/bin/activate
export DISPLAY=:0
export PYTHONPATH=/home/pi/barcode-pi:/usr/lib/python3/dist-packages
export QT_QPA_PLATFORM=xcb
pyuic5 -x neo_bar.ui -o neo_bar.py
python3 YesBarcode.py
EOL

# Create autostart entry
echo "Creating autostart entry..."
cat > ~/.config/autostart/barcode_printer.desktop << EOL
[Desktop Entry]
Type=Application
Name=Barcode Printer
Exec=/bin/bash /home/pi/barcode-pi/run-sleep.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOL

# Create desktop shortcut
echo "Creating desktop shortcut..."
cat > ~/Desktop/BarcodeApp.desktop << EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=Barcode App
Comment=Start Barcode Label Printer
Exec=/bin/bash /home/pi/barcode-pi/run.sh
Icon=/home/pi/barcode-pi/icon.ico
Terminal=false
Categories=Utility;
EOL

# Create systemd service
echo "Creating systemd service..."
sudo tee /etc/systemd/system/barcode-printer.service << EOL
[Unit]
Description=Barcode Printer Application
After=network.target

[Service]
Type=simple
User=pi
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/pi/.Xauthority
Environment=QT_QPA_PLATFORM=xcb
Environment=PYTHONPATH=/home/pi/barcode-pi:/usr/lib/python3/dist-packages
WorkingDirectory=/home/pi/barcode-pi
ExecStart=/bin/bash -c 'source ~/barcode_env/bin/activate && exec /home/pi/barcode-pi/run-sleep.sh'
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOL

# Set permissions
echo "Setting permissions..."
chmod +x ~/.config/autostart/barcode_printer.desktop
chmod +x ~/Desktop/BarcodeApp.desktop
chmod +x ~/barcode-pi/run.sh
chmod +x ~/barcode-pi/run-sleep.sh
chmod +x ~/barcode-pi/YesBarcode.py

# Set desktop file as trusted
gio set ~/Desktop/BarcodeApp.desktop "metadata::trusted" yes

# Enable and start the service
echo "Enabling and starting barcode printer service..."
sudo systemctl enable barcode-printer.service
sudo systemctl start barcode-printer.service

echo "Installation completed!"
echo "Please ensure your Zebra GK420D printer is connected and powered on."
echo "The application will start automatically after reboot."
echo "You can also start it manually using the desktop shortcut."
echo "You may need to restart your system for all changes to take effect." 