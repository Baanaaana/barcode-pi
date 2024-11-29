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