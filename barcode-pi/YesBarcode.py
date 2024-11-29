def load_xml(self):
    self.xml_timer1.stop()
    self.xml_timer1.stop()
    self.label_not_found.setText('Producten laden...')
    QtWidgets.QApplication.processEvents() 
    
    try:
        url = self.url
        r = requests.get(url, stream=True, timeout = 20)
        
        with open('/home/pi/barcode-pi/barcode-label-data.xml', 'wb') as fd:
            for chunk in r.iter_content(2000):
                fd.write(chunk)
        self.label_not_found.setText('Klaar!')                    
    except:
        self.label_not_found.setText('Producten laden mislukt!')
        
    root = ET.parse('/home/pi/barcode-pi/barcode-label-data.xml').getroot()
    self.sku_dict={}
    self.ean_dict={}
    # ... (rest of the code remains the same) 

    self.label_barcode.setPixmap(QtGui.QPixmap("/home/pi/barcode-pi/label.png"))

    icon = QtGui.QIcon()
    icon.addPixmap(QtGui.QPixmap("/home/pi/barcode-pi/refresh.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
    self.btn_refresh.setIcon(icon)