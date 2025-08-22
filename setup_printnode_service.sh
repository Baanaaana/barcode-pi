#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Create systemd service for PrintNode
echo "Creating PrintNode service..."
cat > /etc/systemd/system/printnode.service << EOF
[Unit]
Description=PrintNode Client Service
After=network.target cups.service
Wants=cups.service

[Service]
Type=simple
User=pi
ExecStart=/home/pi/printnode/PrintNode --headless
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Enable and start PrintNode service
echo "Enabling and starting PrintNode service..."
systemctl daemon-reload
systemctl enable printnode.service
systemctl start printnode.service

echo "PrintNode service has been enabled and started"
echo "You can check its status with: systemctl status printnode" 
echo ""
echo "Setup complete! System will reboot in 10 seconds..."
echo "Press Ctrl+C to cancel reboot"
echo ""

# Countdown
for i in {10..1}
do
    echo -ne "\rRebooting in $i seconds... "
    sleep 1
done

echo -e "\rRebooting now...            "
sudo reboot