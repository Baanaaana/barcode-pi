from PyQt5.QtCore import QSettings
import subprocess
import time
import os

def set_feed_url(url):
    # Stop the app and service
    print("Stopping barcode printer service...")
    subprocess.run(['sudo', 'systemctl', 'stop', 'barcode-printer.service'])
    subprocess.run(['pkill', '-f', 'YesBarcode.py'])
    
    # Set the new URL
    settings = QSettings('1', '1')
    settings.setValue('url', url)
    print(f"Feed URL has been set to: {url}")
    
    # Restart the app and service
    print("Restarting barcode printer service...")
    subprocess.run(['sudo', 'systemctl', 'start', 'barcode-printer.service'])
    print("Application restarted with new URL")

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python3 set_url.py <feed_url>")
        sys.exit(1)
    set_feed_url(sys.argv[1]) 