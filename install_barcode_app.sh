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
    python3-pyqt5.qtwidgets \
    libcups2-dev \
    git \
    wget \
    fonts-freefont-ttf \
    python3-venv \
    python3-dev \
    build-essential \
    python3-wheel \
    python3-setuptools

# Remove old installation if exists
echo "Cleaning up old installation..."
sudo systemctl stop barcode-printer.service 2>/dev/null || true
sudo systemctl disable barcode-printer.service 2>/dev/null || true
sudo rm -f /etc/systemd/system/barcode-printer.service
sudo systemctl daemon-reload
rm -rf ~/Desktop/AppV2
rm -rf ~/barcode_env
rm -f ~/Desktop/BarcodeApp.desktop
rm -f ~/.config/autostart/barcode_printer.desktop

# Create virtual environment
echo "Creating Python virtual environment..."
python3 -m venv ~/barcode_env

# Activate virtual environment and install Python packages
echo "Installing Python packages in virtual environment..."
source ~/barcode_env/bin/activate
pip install --upgrade pip wheel setuptools
pip install \
    requests \
    python-barcode \
    pycups \
    pillow \
    appdirs \
    xmltodict \
    PyQt5

# Install CUPS driver for Zebra GK420D
echo "Setting up CUPS for Zebra printer..."
sudo usermod -a -G lpadmin $USER
sudo systemctl start cups
sudo systemctl enable cups

# Create application directory
echo "Creating application directory..."
mkdir -p ~/Desktop/AppV2
cd ~/Desktop/AppV2

# Download the application files from your repository
echo "Downloading application files..."
git clone https://github.com/Baanaaana/barcode-pi.git .
mv AppV2/* .
rm -rf AppV2

# Create required directories and files
mkdir -p ~/.config/autostart

# Update run scripts
echo "Updating run scripts..."
cat > ~/Desktop/AppV2/run.sh << EOL
#!/bin/bash
cd /home/pi/Desktop/AppV2
source ~/barcode_env/bin/activate
export DISPLAY=:0
export PYTHONPATH=/home/pi/Desktop/AppV2
export QT_QPA_PLATFORM=xcb
python3 YesBarcode.py
EOL

cat > ~/Desktop/AppV2/run-sleep.sh << EOL
#!/bin/bash
sleep 10
cd /home/pi/Desktop/AppV2
source ~/barcode_env/bin/activate
export DISPLAY=:0
export PYTHONPATH=/home/pi/Desktop/AppV2
export QT_QPA_PLATFORM=xcb
python3 YesBarcode.py
EOL

# Create autostart entry
echo "Creating autostart entry..."
cat > ~/.config/autostart/barcode_printer.desktop << EOL
[Desktop Entry]
Type=Application
Name=Barcode Printer
Exec=/bin/bash /home/pi/Desktop/AppV2/run-sleep.sh
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
Exec=/bin/bash /home/pi/Desktop/AppV2/run.sh
Icon=/home/pi/Desktop/AppV2/icon.ico
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
WorkingDirectory=/home/pi/Desktop/AppV2
ExecStart=/bin/bash -c 'source ~/barcode_env/bin/activate && exec /home/pi/Desktop/AppV2/run-sleep.sh'
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOL

# Set permissions
echo "Setting permissions..."
chmod +x ~/.config/autostart/barcode_printer.desktop
chmod +x ~/Desktop/BarcodeApp.desktop
chmod +x ~/Desktop/AppV2/run.sh
chmod +x ~/Desktop/AppV2/run-sleep.sh
chmod +x ~/Desktop/AppV2/YesBarcode.py

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