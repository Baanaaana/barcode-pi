from PyQt5 import QtCore, QtWidgets
from neo_bar import Ui_MainWindow

class MainWindowWrapper(Ui_MainWindow):
    def setupUi(self, MainWindow):
        super().setupUi(MainWindow)
        # Apply any necessary adjustments here
        self.spin_copies.setAlignment(QtCore.Qt.AlignCenter)
        self.spin_copies.setButtonSymbols(QtWidgets.QAbstractSpinBox.UpDownArrows)
        self.label_not_found.setFrameShape(QtWidgets.QFrame.NoFrame)
        self.label_not_found.setFrameShadow(QtWidgets.QFrame.Plain)
        self.label_not_found.setAlignment(QtCore.Qt.AlignCenter)
        self.read_product.setContextMenuPolicy(QtCore.Qt.NoContextMenu)
        self.read_product.setAlignment(QtCore.Qt.AlignLeading | QtCore.Qt.AlignLeft | QtCore.Qt.AlignVCenter) 