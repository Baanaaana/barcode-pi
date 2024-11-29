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
    python3-venv

# Create virtual environment
echo "Creating Python virtual environment..."
python3 -m venv ~/barcode_env

# Activate virtual environment and install Python packages
echo "Installing Python packages in virtual environment..."
source ~/barcode_env/bin/activate
pip install \
    requests \
    python-barcode \
    pycups \
    pillow \
    appdirs \
    xmltodict

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

# Update run scripts to use virtual environment
echo "Updating run scripts..."
cat > ~/Desktop/AppV2/run.sh << EOL
#!/bin/bash
source ~/barcode_env/bin/activate
python3 /home/pi/Desktop/AppV2/YesBarcode.py
EOL

cat > ~/Desktop/AppV2/run-sleep.sh << EOL
#!/bin/bash
sleep 10
source ~/barcode_env/bin/activate
python3 /home/pi/Desktop/AppV2/YesBarcode.py
EOL

# Set up autostart directory
echo "Setting up autostart..."
mkdir -p ~/.config/autostart

# Create autostart entry
echo "Creating autostart entry..."
cat > ~/.config/autostart/barcode_printer.desktop << EOL
[Desktop Entry]
Type=Application
Name=Barcode Printer
Exec=bash /home/pi/Desktop/AppV2/run-sleep.sh
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
Exec=bash /home/pi/Desktop/AppV2/run.sh
Icon=/home/pi/Desktop/AppV2/icon.ico
Terminal=false
Categories=Utility;
EOL

# Create systemd service for boot startup
echo "Creating systemd service for boot startup..."
sudo tee /etc/systemd/system/barcode-printer.service << EOL
[Unit]
Description=Barcode Printer Application
After=network.target

[Service]
Type=simple
User=pi
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/pi/.Xauthority
ExecStart=/bin/bash -c 'source ~/barcode_env/bin/activate && /home/pi/Desktop/AppV2/run-sleep.sh'
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the service
echo "Enabling barcode printer service..."
sudo systemctl enable barcode-printer.service
sudo systemctl start barcode-printer.service

# Set permissions
echo "Setting permissions..."
chmod +x ~/.config/autostart/barcode_printer.desktop
chmod +x ~/Desktop/BarcodeApp.desktop
chmod +x ~/Desktop/AppV2/run.sh
chmod +x ~/Desktop/AppV2/run-sleep.sh
chmod +x ~/Desktop/AppV2/YesBarcode.py

echo "Installation completed!"
echo "Please ensure your Zebra GK420D printer is connected and powered on."
echo "The application will start automatically after reboot."
echo "You can also start it manually using the desktop shortcut."
echo "You may need to restart your system for all changes to take effect." 