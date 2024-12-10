from appdirs import user_data_dir
import xml.etree.ElementTree as ET

import subprocess
import requests
import os
os.system('pyuic5 -x neo_bar.ui -o neo_bar.py')
import sys
from PyQt5 import QtWidgets, QtGui, QtCore
from PyQt5.QtCore import Qt
from neo_bar import Ui_MainWindow
from multiprocessing import freeze_support
from PyQt5.QtCore import pyqtSlot, QThread, pyqtSignal

import platform
if platform.system() == 'Linux':
    from zebra import zebra
import textwrap

import os.path
import sys

if sys.platform.lower().startswith('win'):
    IS_WINDOWS = True
    import win32print
else:
    IS_WINDOWS = False

class zebra(object):
    """A class to communicate with (Zebra) label printers using EPL2"""

    def __init__(self, queue=None):
        """queue - name of the printer queue (optional)"""
        self.queue = queue

    def _output_unix(self, commands):
        if self.queue == 'zebra_python_unittest':
            p = subprocess.Popen(['cat','-'], stdin=subprocess.PIPE)
        else:
            p = subprocess.Popen(['lpr','-P{}'.format(self.queue),'-l'], stdin=subprocess.PIPE)
        p.communicate(commands)
        p.stdin.close()

    def _output_win(self, commands):
        if self.queue == 'zebra_python_unittest':
            print (commands)
            return
        hPrinter = win32print.OpenPrinter(self.queue)
        try:
            hJob = win32print.StartDocPrinter(hPrinter, 1, ('Label',None,'RAW'))
            try:
                win32print.StartPagePrinter(hPrinter)
                win32print.WritePrinter(hPrinter, commands)
                win32print.EndPagePrinter(hPrinter)
            finally:
                win32print.EndDocPrinter(hPrinter)
        finally:
            win32print.ClosePrinter(hPrinter)

    def output(self, commands):
        """Output EPL2 commands to the label printer

        commands - EPL2 commands to send to the printer
        """
        assert self.queue is not None
        if sys.version_info[0] == 3:
            if type(commands) != bytes:
                commands = str(commands).encode()
        else:
            commands = str(commands).encode()
        if IS_WINDOWS:
            self._output_win(commands)
        else:
            self._output_unix(commands)

    def _getqueues_unix(self):
        queues = []
        try:
            output = subprocess.check_output(['lpstat','-p'], universal_newlines=True)
        except subprocess.CalledProcessError:
            return []
        for line in output.split('\n'):
            if line.startswith('printer'):
                queues.append(line.split(' ')[1])
        return queues

    def _getqueues_win(self):
        try:
            printers = []
            for (a,b,name,d) in win32print.EnumPrinters(win32print.PRINTER_ENUM_LOCAL):
                printers.append(name)
            return printers
        except:
            return []

    def getqueues(self):
        """Returns a list of printer queues on local machine"""
        if IS_WINDOWS:
            return self._getqueues_win()
        else:
            return self._getqueues_unix()

    def setqueue(self, queue):
        """Set the printer queue"""
        self.queue = queue

    def setup(self, direct_thermal=None, label_height=None, label_width=None):
        """Set up the label printer. Parameters are not set if they are None.

        direct_thermal - True if using direct thermal labels
        label_height   - tuple (label height, label gap) in dots
        label_width    - in dots
        """
        commands = '\n'
        if direct_thermal:
            commands += ('OD\n')
        if label_height:
           commands += ('Q%s,%s\n'%(label_height[0],label_height[1]))
        if label_width:
            commands += ('q%s\n'%label_width)
        self.output(commands)

    def store_graphic(self, name, filename):
        """Store a .PCX file on the label printer

        name     - name to be used on printer
        filename - local filename
        """
        assert filename.lower().endswith('.pcx')
        commands = '\nGK"%s"\n'%name
        commands += 'GK"%s"\n'%name
        size = os.path.getsize(filename)
        commands += 'GM"%s"%s\n'%(name,size)
        self.output(commands)
        self.output(open(filename,'rb').read())


class MainWindow_exec(QtWidgets.QMainWindow, Ui_MainWindow):
    def __init__(self, parent=None):
        QtWidgets.QMainWindow.__init__(self, parent)
        self.setupUi(self)
        self.settings = QtCore.QSettings('1','1')
        self.url=self.settings.value('url','please udpate your xml link here')
        self.box_url.setText(self.url)

        self.default_printer=self.settings.value('default_printer','')
#        self.copies=self.settings.value('copies','1')
        self.autoprint=self.settings.value('autoprint',True)
        print(self.autoprint)
        if self.autoprint=='true':
            self.autoprint=True
        elif self.autoprint=='false':
            self.autoprint=False

#        self.spin_copies.setValue(int(self.copies))
        self.check_autoprint.setChecked(self.autoprint)

        print( self.spin_copies.value() )
        
        self.spin_copies.valueChanged.connect(self.set_copies)
        self.check_autoprint.stateChanged.connect(self.set_autoprint)
        self.combo_printers.currentIndexChanged.connect(self.change_printer)


        self.z = zebra()

        self.btn_refresh.clicked.connect(self.show_printer)
        self.show_printer()






        self.spin_copies.valueChanged.connect(self.set_copies)
        self.check_autoprint.stateChanged.connect(self.set_autoprint)
        self.btn_print.clicked.connect(self.manual_printing)

        self.combo_printers.setFocusPolicy(QtCore.Qt.NoFocus)
        self.btn_refresh.setFocusPolicy(QtCore.Qt.NoFocus)
#        self.spin_copies.setFocusPolicy(QtCore.Qt.NoFocus)
        self.check_autoprint.setFocusPolicy(QtCore.Qt.NoFocus)
        self.btn_print.setFocusPolicy(QtCore.Qt.NoFocus)
        self.label_barcode.setFocusPolicy(QtCore.Qt.NoFocus)
 
        self.label_barcode.setPixmap(QtGui.QPixmap("/home/pi/barcode-pi/label.png"))

#        self.btn_refresh.setPixmap(QtGui.QPixmap("/home/pi/barcode-pi/refresh.png"))
        icon = QtGui.QIcon()
        icon.addPixmap(QtGui.QPixmap("/home/pi/barcode-pi/refresh.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        self.btn_refresh.setIcon(icon)

        self.xml_timer = QtCore.QTimer(self)
        self.xml_timer.timeout.connect(self.load_xml)
        self.xml_timer.start(1000*60*60)

        self.xml_timer1 = QtCore.QTimer(self)
        self.xml_timer1.timeout.connect(self.load_xml)
        self.xml_timer1.start(1000)
        self.label_not_found.setText('Producten laden...')
        
        self.btn_save.clicked.connect(self.save_url)
        self.box_url.setFocusPolicy( Qt.NoFocus )
        self.box_url.installEventFilter(self)
        self.read_product.setFocus(True)
        
        
        if self.spin_copies.value()>1:
            self.check_autoprint.setChecked(False)
            
        
            

    def eventFilter(self, watched, event):
        if watched == self.box_url and event.type() == QtCore.QEvent.MouseButtonDblClick:
            print("pos: ", event.pos())
            self.box_url.setFocusPolicy( Qt.StrongFocus )
            self.box_url.setStyleSheet('background-color:green;color:white')
            # do something
        return QtWidgets.QWidget.eventFilter(self, watched, event)


    def save_url(self):
        self.settings.setValue('url',self.box_url.text())
        self.box_url.setStyleSheet('')
        self.settings.sync()
        sys.exit(0)

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
        for type_tag in root.findall('item'):    
            sku=None
            barcode=None
            prodname=None
            try:
                sku=type_tag.findall('sku')[0].text
            except:
                None
            try:
                barcode=type_tag.findall('barcode')[0].text
            except:
                None
            try:
                prodname=type_tag.findall('productname')[0].text
            except:
                None
            self.sku_dict[sku]=[barcode,prodname]
            self.ean_dict[barcode]=[sku,prodname]



    def closeEvent(self,event):
        sys.exit(0)

    def manual_printing(self):
        print('manual printing')
        self.call_decode(True)

    def set_copies(self):
        self.settings.setValue('copies',self.spin_copies.value())
        self.settings.sync()
        if self.spin_copies.value()>1:
            self.check_autoprint.setChecked(False)
    def set_autoprint(self):
        self.settings.setValue('autoprint',self.check_autoprint.isChecked())
        self.settings.sync()


    def keyPressEvent(self,event):
        print(event.key())
        if event.key()==QtCore.Qt.Key_Escape:
            print('esc')
            self.read_product.clear()
            self.label_not_found.setText('')
        elif event.key()==QtCore.Qt.Key_Return or event.key()==16777221 or event.key()==16777220:
            print('enter')
            self.call_decode()
        elif event.key()==QtCore.Qt.Key_Backspace:
            print('enter')
            self.read_product.setText(self.read_product.text()[:-1])
        else:
            try:
                self.read_product.setText( self.read_product.text()+chr(event.key()) )
            except Exception as e:
                print('special keys',e)

    def call_decode(self, manual_print=False):
        self.label_not_found.setText('')
        sku = ''
        ean = ''
        prodname = ''

        if len(self.read_product.text()) == 0:
            print('enter something')
            return
        elif self.read_product.text().count('-') == 3:
            self.print_qr_barcode(self.read_product.text(), manual_print)
            return
        else:
            if len(self.read_product.text())<12:
                try:
                    print(self.sku_dict[self.read_product.text()])
                    lst=self.sku_dict[self.read_product.text()]
                    
                    sku=self.read_product.text()+'~'
                    ean=lst[0]
                    prodname=lst[1]
                    
                except:
                    print('No product for sku,return')
                    self.label_not_found.setText('Artikelnummer onbekend')
                    self.read_product.clear()
                    self.read_product.setFocus(True)
                    return;
            elif len(self.read_product.text())>=12:
                if len(self.read_product.text().split('~'))>1:
                    print('Auto print keep ean, reprocess')
                    self.read_product.setText(self.read_product.text().split('~')[1])
                try:
                    ean=self.read_product.text()

                    print(self.ean_dict[self.read_product.text()])
                    lst=self.ean_dict[self.read_product.text()]
                    
                    sku=lst[0]+'~'
                    prodname=lst[1]
                except:
                    print('No product for ean,continue')
                    self.label_not_found.setText('EAN niet bekend. Printen...')
            else:
                print('Minimaal 6 of maximaal 13 tekens')
                self.label_not_found.setText('Minimaal 6 of maximaal 13 tekens')
                self.read_product.clear()
                return;
                
            if prodname==None:
                prodname=''

            print('SKU:',sku)
            print('EAN:',ean)
            print('PRD:',prodname)
            
            self.read_product.setText(sku+ean)
            QtWidgets.QApplication.processEvents()

              
            if len(prodname) <= 28:
                if 'ZebraBarcode' in self.combo_printers.currentText():
                    if len(ean) == 12:
                        zpl = '^XA^LH0,20^FO30,20^A0,30^FD' + prodname + '^FS^FO340,80^A0,20^FDUPC^FS^FO30,60^BY3^BUN,60,N,N,N,N^FD' + ean + '^FS^FO30,150^A0,30^FD' + sku + ean + '^FS^XZ'
                    else:
                        zpl = '^XA^LH0,20^FO30,20^A0,30^FD' + prodname + '^FS^FO340,80^A0,20^FDEAN^FS^FO30,60^BY3^BEN,60,N,N,N,N^FD' + ean + '^FS^FO30,150^A0,30^FD' + sku + ean + '^FS^XZ'
            else:
                tlist = textwrap.fill(prodname, 28).split('\n')
                if 'ZebraBarcode' in self.combo_printers.currentText():
                    if len(ean) == 12:
                        zpl = '^XA^LH0,25^FO30,10^A0,30^FD' + tlist[0] + '^FS^FO30,50^A0,30^FD' + tlist[1] + '^FS^FO340,110^A0,20^FDUPC^FS^FO30,90^BY3^BUN,60,N,N,N,N^FD' + ean + '^FS^FO30,180^A0,30^FD' + sku + ean + '^FS^XZ'
                    else:
                        zpl = '^XA^LH0,25^FO30,10^A0,30^FD' + tlist[0] + '^FS^FO30,50^A0,30^FD' + tlist[1] + '^FS^FO340,110^A0,20^FDEAN^FS^FO30,90^BY3^BEN,60,N,N,N,N^FD' + ean + '^FS^FO30,180^A0,30^FD' + sku + ean + '^FS^XZ'

            print('printer command:', zpl)
            zpl = zpl.replace('~', '-')

            if manual_print or self.check_autoprint.isChecked():
                for x in range(0, self.spin_copies.value()):
                    z = zebra()
                    print('Printer queues found:', z.getqueues())
                    z.setqueue(self.combo_printers.currentText())
                    z.setup(direct_thermal=True, label_height=(256, 32), label_width=456)  # 3" x 2" direct thermal label
                    z.output(zpl)
                    print(zpl)
            else:
                print('Printing disabled')
            if manual_print or self.check_autoprint.isChecked():
                self.read_product.clear()
                self.label_barcode.setPixmap(QtGui.QPixmap("/home/pi/barcode-pi/label.png"))
                self.label_barcode.update_label()
                self.spin_copies.setValue(1)
            self.read_product.setFocus(True)

    def print_qr_barcode(self, ean, manual_print):
        """Print a QR barcode for 11-digit input."""
        container = ean[-1]  # Last digit as container
        zpl = (
            '^XA^LH0,25^FO30,0^A0,60^FD' + ean +
            '^FS^FO50,10^BQN,2,6^FDMA,' + ean +
            '^FS^FO280,90^CFB,100^FD' + container +
            '^FS^XZ'
        )
        print('QR printer command:', zpl)

        if manual_print or self.check_autoprint.isChecked():
            for x in range(0, self.spin_copies.value()):
                z = zebra()
                print('Printer queues found:', z.getqueues())
                z.setqueue(self.combo_printers.currentText())
                z.setup(direct_thermal=True, label_height=(256, 32), label_width=456)
                z.output(zpl)
                print(zpl)
        else:
            print('Printing disabled')

        self.read_product.clear()
        self.label_barcode.setPixmap(QtGui.QPixmap("/home/pi/barcode-pi/label.png"))
        self.label_barcode.update_label()
        self.spin_copies.setValue(1)
        self.read_product.setFocus(True)

    def start_printing(self):
        print(self.read_ean.text())
    def change_printer(self):
        print(self.combo_printers.currentText())
        self.settings.setValue('default_printer',self.combo_printers.currentText())
        self.settings.sync()
        self.z.setqueue( self.combo_printers.currentText() )
        self.setFocus(True)

        
    def show_printer(self):

        self.combo_printers.blockSignals(True)
        self.combo_printers.clear()
        self.combo_printers.addItems(self.z.getqueues())        
        self.combo_printers.setCurrentText   ( self.settings.value('default_printer','') )
        self.combo_printers.blockSignals(False)

        
if __name__ == '__main__':
    freeze_support()

    app = QtWidgets.QApplication(sys.argv)
    s = QtWidgets.QStyleFactory.create('Fusion')
    app.setStyle(s)
#    app.setOverrideCursor(Qt.BlankCursor);
    app_icon = QtGui.QIcon()
    app_icon.addFile('icon.ico', QtCore.QSize(16,16))
    app_icon.addFile('icon.ico', QtCore.QSize(24,24))
    app_icon.addFile('icon.ico', QtCore.QSize(32,32))
    app_icon.addFile('icon.ico', QtCore.QSize(48,48))
    app_icon.addFile('icon.ico', QtCore.QSize(256,256))
    app.setWindowIcon(app_icon)


    # Set application style. Styles: WindowsVista,Windows,Fusion
    s = QtWidgets.QStyleFactory.create('Fusion')
    app.setStyle(s)


    MainWindow1 = MainWindow_exec()
    MainWindow1.showFullScreen()
    sys.exit(app.exec_())
