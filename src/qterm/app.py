"""
Qt serial terminal application
"""

import sys

from pathlib import Path
from PySide6.QtCore import (
    Qt,
    QObject,
    QThread,
    QTimer,
    QUrl,
    QFile,
    Property,
    Signal,
    Slot,
)
from PySide6.QtStateMachine import QStateMachine, QState
from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import (
    QQmlApplicationEngine,
    qmlRegisterType,
    qmlRegisterSingletonType,
)
from serial.tools import list_ports as ports
from importlib import metadata as meta

# Register qrc resources to use string literal references
# noinspection PyUnresolvedReferences
from qterm.resources import resources
from qterm.device import SerialDevice


VIEW_PATH = Path(__file__).parent / "view"


class Worker(QObject):
    incomingData = Signal(str)

    def __init__(self, device: SerialDevice):
        super().__init__()

        self.device = device

    @Slot(result=None)
    def run(self) -> None:
        while self.device.is_open:
            try:
                if self.device.in_waiting:
                    self.incomingData.emit(self.device.recv())
            except OSError:
                # Device may have been closed externally
                break


class StateMachine(QStateMachine):
    stateChanged = Signal()

    def __init__(self, parent: QObject):
        super().__init__(parent=parent)

        self.closed = QState(parent=self)
        self.open = QState(parent=self)

        self.closed.entered.connect(self.stateChanged, Qt.QueuedConnection)
        self.open.entered.connect(self.stateChanged, Qt.QueuedConnection)

        self.setInitialState(self.closed)

    @Property(bool, notify=stateChanged)
    def hasClosedState(self) -> bool:
        return self.closed in self.configuration()

    @Property(bool, notify=stateChanged)
    def hasOpenState(self) -> bool:
        return self.open in self.configuration()


class Controller(QObject):
    deviceOpened = Signal()
    deviceClosed = Signal()
    modelChanged = Signal()
    statusChanged = Signal(str)
    messageReceived = Signal(str)
    fileDataProcessed = Signal(str)
    quitting = Signal()

    def __init__(self, parent: QGuiApplication):
        super().__init__(parent=parent)

        self._model = []
        self.device: SerialDevice | None = None
        self.thread: QThread | None = None
        self.worker: Worker | None = None

        self.machine = StateMachine(self)
        self.machine.closed.addTransition(self.deviceOpened, self.machine.open)
        self.machine.open.addTransition(self.deviceClosed, self.machine.closed)
        self.machine.start()

        # Periodically inspect device comports
        self.timer = QTimer()
        self.timer.setInterval(700)
        # noinspection PyUnresolvedReferences
        self.timer.timeout.connect(self.getModel)
        self.deviceClosed.connect(self.timer.start, Qt.QueuedConnection)
        self.deviceOpened.connect(self.timer.stop, Qt.QueuedConnection)
        self.timer.start()

    @Property(list, notify=modelChanged)
    def model(self) -> list:
        return self._model

    @model.setter
    def model(self, devs: list) -> None:
        self._model = devs
        self.modelChanged.emit()

    @Slot(result=None)
    def shutdown(self) -> None:
        """Hijack shutdown procedure from frontend"""
        self.quitting.emit()  # Close devices and worker threads

        if self.timer.isActive():
            self.timer.stop()

        # Wait 100 ms for serial devices and threads to close
        self.timer.singleShot(100, QGuiApplication.quit)

    # noinspection PyPropertyAccess
    @Slot(result=None)
    def getModel(self) -> None:
        """Collect serial comport information"""
        model = [
            f"{com.name}: {com.product} | {com.manufacturer}"
            for com in ports.comports()
            if "Bluetooth" not in com.device
            and (com.product is not None and com.manufacturer is not None)
        ]

        if self.model != model:
            self.model = model
            if len(self.model):
                self.statusChanged.emit("Serial comports detected")
            else:
                self.statusChanged.emit("Serial comports not found")

    @Slot(str, result=None)
    def forwardMessage(self, message: str) -> None:
        if self.device.is_open:
            self.device.send(message)

    @Slot(str, result=None)
    def transferTextFile(self, path: str) -> None:
        if self.device.is_open:
            file = QFile(QUrl(path).toLocalFile())
            file.open(QFile.ReadOnly)
            data = file.readAll()
            file.close()
            self.device.send(data)
            for line in data.data().decode("utf-8").split("\n"):
                self.fileDataProcessed.emit(line)

    # noinspection PyUnresolvedReferences
    @Slot(str, int, str, result=None)
    def connectSerialDevice(self, name: str, baudrate: int, delimiter: str) -> None:
        """Open serial device if not already opened"""
        if self.machine.closed in self.machine.configuration():
            for com in ports.comports():
                if com.name == name:
                    self.device = SerialDevice(
                        port=com.device, baudrate=baudrate, delimiter=delimiter
                    )
                    # Start worker thread
                    self.thread = QThread()
                    self.worker = Worker(self.device)
                    self.worker.moveToThread(self.thread)
                    self.worker.incomingData.connect(
                        self.messageReceived, Qt.QueuedConnection
                    )
                    self.thread.finished.connect(
                        self.thread.deleteLater, Qt.QueuedConnection
                    )
                    self.thread.started.connect(self.worker.run, Qt.QueuedConnection)
                    self.deviceClosed.connect(self.thread.quit, Qt.QueuedConnection)
                    self.deviceOpened.connect(self.thread.start, Qt.QueuedConnection)
                    self.quitting.connect(self.closeSerialDevice, Qt.QueuedConnection)
                    self.quitting.connect(self.thread.quit, Qt.QueuedConnection)

                    self.deviceOpened.emit()
                    self.statusChanged.emit(
                        f"Device {com.product} opened on {com.device}"
                    )

    @Slot(result=None)
    def closeSerialDevice(self) -> None:
        if self.device.is_open:
            self.device.close()
            self.deviceClosed.emit()
            self.statusChanged.emit("Serial comports detected")


def main() -> None:
    # Find the name of the module that was used to start the app
    module = sys.modules["__main__"].__package__
    # Retrieve the application metadata
    metadata = meta.metadata(module)

    app = QGuiApplication(sys.argv)
    app.setApplicationName(metadata["Formal-Name"])
    app.setWindowIcon(QIcon(":/appicon"))
    engine = QQmlApplicationEngine()

    qmlRegisterSingletonType("qrc:/style", "Style", 1, 0, "Style")
    qmlRegisterType("qrc:/component/drop-down", "DropDown", 1, 0, "DropDown")
    qmlRegisterType("qrc:/component/image-button", "ImageButton", 1, 0, "ImageButton")
    qmlRegisterType("qrc:/component/text-input", "TextInput", 1, 0, "TextInput")
    qmlRegisterType("qrc:/composite/tool-bar", "ToolBar", 1, 0, "ToolBar")
    qmlRegisterType("qrc:/composite/text-view", "TextView", 1, 0, "TextView")
    qmlRegisterType("qrc:/composite/prompt", "Prompt", 1, 0, "Prompt")

    # Controller must be instantiated after QmlApplicationEngine,
    # otherwise it will not have access to the Qt event loop (needed for QTimer!)
    controller = Controller(parent=app)

    engine.rootContext().setContextProperty("controller", controller)
    engine.rootContext().setContextProperty("machine", controller.machine)
    engine.load(VIEW_PATH / "main.qml")

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
