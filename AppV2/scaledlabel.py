from PyQt5 import QtWidgets,QtGui,QtCore
class scaledlabel(QtWidgets.QLabel):
    def __init__(self, *args, **kwargs):
        QtWidgets.QLabel.__init__(self)
        self.setPixmap(QtGui.QPixmap("/home/pi/Desktop/AppV2/label.png"))
#        self.setScaledContents(True)

        self._pixmap = QtGui.QPixmap(self.pixmap())
        

    def resizeEvent(self, event=None):
        self.setPixmap(self._pixmap.scaled(
            self.width(), self.height(),
            QtCore.Qt.KeepAspectRatio,QtCore.Qt.SmoothTransformation))
    def update_label(self):
        self._pixmap = QtGui.QPixmap(self.pixmap())
        self.setPixmap(self._pixmap.scaled(
            self.width(), self.height(),
            QtCore.Qt.KeepAspectRatio,QtCore.Qt.SmoothTransformation))
