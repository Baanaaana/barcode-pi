# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'neo_bar.ui'
#
# Created by: PyQt5 UI code generator 5.11.3
#
# WARNING! All changes made in this file will be lost!

from PyQt5 import QtCore, QtGui, QtWidgets

class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(800, 480)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(MainWindow.sizePolicy().hasHeightForWidth())
        MainWindow.setSizePolicy(sizePolicy)
        MainWindow.setMinimumSize(QtCore.QSize(800, 480))
        MainWindow.setMaximumSize(QtCore.QSize(1920, 1080))
        font = QtGui.QFont()
        font.setPointSize(16)
        MainWindow.setFont(font)
        icon = QtGui.QIcon()
        icon.addPixmap(QtGui.QPixmap("icon.ico"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        MainWindow.setWindowIcon(icon)
        self.centralwidget = QtWidgets.QWidget(MainWindow)
        self.centralwidget.setObjectName("centralwidget")
        self.gridLayout = QtWidgets.QGridLayout(self.centralwidget)
        self.gridLayout.setObjectName("gridLayout")
        self.widget = QtWidgets.QWidget(self.centralwidget)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Preferred, QtWidgets.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(3)
        sizePolicy.setHeightForWidth(self.widget.sizePolicy().hasHeightForWidth())
        self.widget.setSizePolicy(sizePolicy)
        self.widget.setMinimumSize(QtCore.QSize(780, 200))
        self.widget.setMaximumSize(QtCore.QSize(780, 200))
        self.widget.setObjectName("widget")
        self.gridLayout_6 = QtWidgets.QGridLayout(self.widget)
        self.gridLayout_6.setObjectName("gridLayout_6")
        self.label_barcode = scaledlabel(self.widget)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.label_barcode.sizePolicy().hasHeightForWidth())
        self.label_barcode.setSizePolicy(sizePolicy)
        self.label_barcode.setMinimumSize(QtCore.QSize(220, 180))
        self.label_barcode.setMaximumSize(QtCore.QSize(220, 180))
        self.label_barcode.setObjectName("label_barcode")
        self.widget_7 = QtWidgets.QWidget(self.label_barcode)
        self.widget_7.setGeometry(QtCore.QRect(-20, 0, 18, 253))
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Maximum, QtWidgets.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(4)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.widget_7.sizePolicy().hasHeightForWidth())
        self.widget_7.setSizePolicy(sizePolicy)
        self.widget_7.setObjectName("widget_7")
        self.gridLayout_8 = QtWidgets.QGridLayout(self.widget_7)
        self.gridLayout_8.setContentsMargins(0, 0, 0, 0)
        self.gridLayout_8.setObjectName("gridLayout_8")
        self.gridLayout_6.addWidget(self.label_barcode, 0, 1, 1, 1)
        self.widget_6 = QtWidgets.QWidget(self.widget)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.widget_6.sizePolicy().hasHeightForWidth())
        self.widget_6.setSizePolicy(sizePolicy)
        self.widget_6.setMinimumSize(QtCore.QSize(510, 180))
        self.widget_6.setMaximumSize(QtCore.QSize(510, 180))
        self.widget_6.setObjectName("widget_6")
        self.btn_print = QtWidgets.QPushButton(self.widget_6)
        self.btn_print.setGeometry(QtCore.QRect(300, 30, 180, 110))
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.btn_print.sizePolicy().hasHeightForWidth())
        self.btn_print.setSizePolicy(sizePolicy)
        self.btn_print.setMinimumSize(QtCore.QSize(180, 110))
        self.btn_print.setMaximumSize(QtCore.QSize(180, 110))
        font = QtGui.QFont()
        font.setFamily("FreeSans")
        font.setPointSize(24)
        font.setBold(True)
        font.setWeight(75)
        self.btn_print.setFont(font)
        self.btn_print.setCursor(QtGui.QCursor(QtCore.Qt.PointingHandCursor))
        self.btn_print.setStyleSheet("background-color:#0099fe;color:#ffffff;border-radius:5px;")
        self.btn_print.setObjectName("btn_print")
        self.spin_copies = QtWidgets.QSpinBox(self.widget_6)
        self.spin_copies.setGeometry(QtCore.QRect(0, 20, 250, 160))
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.spin_copies.sizePolicy().hasHeightForWidth())
        self.spin_copies.setSizePolicy(sizePolicy)
        self.spin_copies.setMinimumSize(QtCore.QSize(250, 160))
        self.spin_copies.setMaximumSize(QtCore.QSize(250, 160))
        font = QtGui.QFont()
        font.setFamily("FreeSans")
        font.setPointSize(80)
        font.setBold(True)
        font.setWeight(75)
        self.spin_copies.setFont(font)
        self.spin_copies.setCursor(QtGui.QCursor(QtCore.Qt.PointingHandCursor))
        self.spin_copies.setStyleSheet("QSpinBox::up-button{width:50px}\n"
"QSpinBox::down-button{width:50px}")
        self.spin_copies.setFrame(True)
        self.spin_copies.setAlignment(QtCore.Qt.AlignCenter)
        self.spin_copies.setButtonSymbols(QtWidgets.QAbstractSpinBox.UpDownArrows)
        self.spin_copies.setMinimum(1)
        self.spin_copies.setMaximum(100)
        self.spin_copies.setProperty("value", 1)
        self.spin_copies.setObjectName("spin_copies")
        self.check_autoprint = QtWidgets.QCheckBox(self.widget_6)
        self.check_autoprint.setGeometry(QtCore.QRect(330, 140, 125, 40))
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.check_autoprint.sizePolicy().hasHeightForWidth())
        self.check_autoprint.setSizePolicy(sizePolicy)
        self.check_autoprint.setMinimumSize(QtCore.QSize(125, 40))
        self.check_autoprint.setMaximumSize(QtCore.QSize(125, 40))
        font = QtGui.QFont()
        font.setFamily("FreeSans")
        font.setPointSize(10)
        font.setBold(False)
        font.setWeight(50)
        self.check_autoprint.setFont(font)
        self.check_autoprint.setStyleSheet("QCheckBox::indicator { width: 25px; height: 25px;}")
        self.check_autoprint.setChecked(True)
        self.check_autoprint.setObjectName("check_autoprint")
        self.gridLayout_6.addWidget(self.widget_6, 0, 0, 1, 1)
        self.label_not_found = QtWidgets.QLabel(self.widget)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.label_not_found.sizePolicy().hasHeightForWidth())
        self.label_not_found.setSizePolicy(sizePolicy)
        self.label_not_found.setMinimumSize(QtCore.QSize(220, 25))
        self.label_not_found.setMaximumSize(QtCore.QSize(220, 25))
        font = QtGui.QFont()
        font.setFamily("FreeSans")
        font.setPointSize(10)
        font.setBold(False)
        font.setWeight(50)
        self.label_not_found.setFont(font)
        self.label_not_found.setStyleSheet("color:#444444")
        self.label_not_found.setFrameShape(QtWidgets.QFrame.NoFrame)
        self.label_not_found.setFrameShadow(QtWidgets.QFrame.Plain)
        self.label_not_found.setText("")
        self.label_not_found.setAlignment(QtCore.Qt.AlignCenter)
        self.label_not_found.setObjectName("label_not_found")
        self.gridLayout_6.addWidget(self.label_not_found, 1, 1, 1, 1)
        self.gridLayout.addWidget(self.widget, 2, 0, 1, 1)
        self.widget_5 = QtWidgets.QWidget(self.centralwidget)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.widget_5.sizePolicy().hasHeightForWidth())
        self.widget_5.setSizePolicy(sizePolicy)
        self.widget_5.setMinimumSize(QtCore.QSize(780, 200))
        self.widget_5.setMaximumSize(QtCore.QSize(780, 200))
        font = QtGui.QFont()
        font.setPointSize(14)
        self.widget_5.setFont(font)
        self.widget_5.setObjectName("widget_5")
        self.read_product = QtWidgets.QLineEdit(self.widget_5)
        self.read_product.setEnabled(True)
        self.read_product.setGeometry(QtCore.QRect(20, 30, 740, 150))
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.read_product.sizePolicy().hasHeightForWidth())
        self.read_product.setSizePolicy(sizePolicy)
        self.read_product.setMinimumSize(QtCore.QSize(740, 150))
        self.read_product.setMaximumSize(QtCore.QSize(740, 150))
        font = QtGui.QFont()
        font.setFamily("FreeSans")
        font.setPointSize(48)
        font.setBold(False)
        font.setItalic(False)
        font.setWeight(50)
        font.setStrikeOut(False)
        font.setKerning(False)
        self.read_product.setFont(font)
        self.read_product.setContextMenuPolicy(QtCore.Qt.NoContextMenu)
        self.read_product.setText("")
        self.read_product.setMaxLength(30)
        self.read_product.setFrame(True)
        self.read_product.setCursorPosition(0)
        self.read_product.setAlignment(QtCore.Qt.AlignLeading|QtCore.Qt.AlignLeft|QtCore.Qt.AlignVCenter)
        self.read_product.setReadOnly(False)
        self.read_product.setObjectName("read_product")
        self.gridLayout.addWidget(self.widget_5, 1, 0, 1, 1)
        self.widget_2 = QtWidgets.QWidget(self.centralwidget)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Preferred, QtWidgets.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(2)
        sizePolicy.setHeightForWidth(self.widget_2.sizePolicy().hasHeightForWidth())
        self.widget_2.setSizePolicy(sizePolicy)
        self.widget_2.setMinimumSize(QtCore.QSize(780, 50))
        self.widget_2.setMaximumSize(QtCore.QSize(780, 50))
        self.widget_2.setObjectName("widget_2")
        self.gridLayout_2 = QtWidgets.QGridLayout(self.widget_2)
        self.gridLayout_2.setObjectName("gridLayout_2")
        self.widget_3 = QtWidgets.QWidget(self.widget_2)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.widget_3.sizePolicy().hasHeightForWidth())
        self.widget_3.setSizePolicy(sizePolicy)
        self.widget_3.setMinimumSize(QtCore.QSize(380, 40))
        self.widget_3.setMaximumSize(QtCore.QSize(380, 40))
        self.widget_3.setObjectName("widget_3")
        self.box_url = QtWidgets.QLineEdit(self.widget_3)
        self.box_url.setGeometry(QtCore.QRect(30, 0, 250, 40))
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.box_url.sizePolicy().hasHeightForWidth())
        self.box_url.setSizePolicy(sizePolicy)
        self.box_url.setMinimumSize(QtCore.QSize(250, 40))
        self.box_url.setMaximumSize(QtCore.QSize(250, 40))
        font = QtGui.QFont()
        font.setFamily("FreeSans")
        font.setPointSize(10)
        font.setBold(False)
        font.setItalic(False)
        font.setWeight(50)
        self.box_url.setFont(font)
        self.box_url.setObjectName("box_url")
        self.btn_save = QtWidgets.QPushButton(self.widget_3)
        self.btn_save.setGeometry(QtCore.QRect(290, 0, 80, 40))
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.btn_save.sizePolicy().hasHeightForWidth())
        self.btn_save.setSizePolicy(sizePolicy)
        self.btn_save.setMinimumSize(QtCore.QSize(80, 40))
        self.btn_save.setMaximumSize(QtCore.QSize(80, 40))
        font = QtGui.QFont()
        font.setFamily("FreeSans")
        font.setPointSize(12)
        font.setBold(True)
        font.setWeight(75)
        self.btn_save.setFont(font)
        self.btn_save.setCursor(QtGui.QCursor(QtCore.Qt.PointingHandCursor))
        self.btn_save.setStyleSheet("background-color:#0099fe;color:#ffffff;border-radius:5px;")
        self.btn_save.setObjectName("btn_save")
        self.gridLayout_2.addWidget(self.widget_3, 0, 1, 1, 1)
        self.widget_4 = QtWidgets.QWidget(self.widget_2)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.widget_4.sizePolicy().hasHeightForWidth())
        self.widget_4.setSizePolicy(sizePolicy)
        self.widget_4.setMinimumSize(QtCore.QSize(380, 40))
        self.widget_4.setMaximumSize(QtCore.QSize(380, 40))
        self.widget_4.setObjectName("widget_4")
        self.combo_printers = QtWidgets.QComboBox(self.widget_4)
        self.combo_printers.setGeometry(QtCore.QRect(10, 0, 250, 40))
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.combo_printers.sizePolicy().hasHeightForWidth())
        self.combo_printers.setSizePolicy(sizePolicy)
        self.combo_printers.setMinimumSize(QtCore.QSize(250, 40))
        self.combo_printers.setMaximumSize(QtCore.QSize(250, 40))
        font = QtGui.QFont()
        font.setFamily("FreeSans")
        font.setPointSize(10)
        font.setBold(False)
        font.setWeight(50)
        self.combo_printers.setFont(font)
        self.combo_printers.setCursor(QtGui.QCursor(QtCore.Qt.PointingHandCursor))
        self.combo_printers.setObjectName("combo_printers")
        self.btn_refresh = QtWidgets.QPushButton(self.widget_4)
        self.btn_refresh.setGeometry(QtCore.QRect(270, 0, 80, 40))
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.btn_refresh.sizePolicy().hasHeightForWidth())
        self.btn_refresh.setSizePolicy(sizePolicy)
        self.btn_refresh.setMinimumSize(QtCore.QSize(80, 40))
        self.btn_refresh.setMaximumSize(QtCore.QSize(80, 40))
        font = QtGui.QFont()
        font.setPointSize(30)
        font.setBold(True)
        font.setWeight(75)
        self.btn_refresh.setFont(font)
        self.btn_refresh.setCursor(QtGui.QCursor(QtCore.Qt.PointingHandCursor))
        self.btn_refresh.setStyleSheet("background-color:#0099fe;color:#ffffff;border-radius:5px;")
        self.btn_refresh.setText("")
        icon1 = QtGui.QIcon()
        icon1.addPixmap(QtGui.QPixmap("refresh.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        self.btn_refresh.setIcon(icon1)
        self.btn_refresh.setIconSize(QtCore.QSize(20, 20))
        self.btn_refresh.setObjectName("btn_refresh")
        self.gridLayout_2.addWidget(self.widget_4, 0, 0, 1, 1)
        self.gridLayout.addWidget(self.widget_2, 0, 0, 1, 1)
        MainWindow.setCentralWidget(self.centralwidget)

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        _translate = QtCore.QCoreApplication.translate
        MainWindow.setWindowTitle(_translate("MainWindow", "Barcode Label Printer"))
        self.btn_print.setText(_translate("MainWindow", "PRINT"))
        self.check_autoprint.setText(_translate("MainWindow", "AUTO PRINT"))
        self.read_product.setPlaceholderText(_translate("MainWindow", "EAN / SKU"))
        self.btn_save.setText(_translate("MainWindow", "SAVE"))

from scaledlabel import scaledlabel

if __name__ == "__main__":
    import sys
    app = QtWidgets.QApplication(sys.argv)
    MainWindow = QtWidgets.QMainWindow()
    ui = Ui_MainWindow()
    ui.setupUi(MainWindow)
    MainWindow.show()
    sys.exit(app.exec_())

