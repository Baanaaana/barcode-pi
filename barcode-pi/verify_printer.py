#!/usr/bin/env python3
import subprocess

def check_printer(printer_name):
    try:
        # Check if the printer is available
        result = subprocess.run(['lpstat', '-p', printer_name], capture_output=True, text=True)
        if result.returncode == 0:
            print(f"Printer '{printer_name}' is installed and available.")
        else:
            print(f"Printer '{printer_name}' is not available. Please check the setup.")
    except Exception as e:
        print(f"An error occurred while checking printer '{printer_name}': {e}")

def main():
    # Define printer names
    barcode_printer = "ZebraBarcode"
    shipping_printer = "ZebraShipping"

    # Verify both printers
    print("Verifying printers...")
    check_printer(barcode_printer)
    check_printer(shipping_printer)

if __name__ == "__main__":
    main() 