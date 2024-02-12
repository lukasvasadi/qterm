// noinspection JSUnresolvedReference

import QtQuick
import QtQuick.Controls
import Qt.labs.platform
import ToolBar
import TextView
import Prompt
import Style

ApplicationWindow {
    id: root

    function calcWidth(): int {
        return (root.width < 800 ? root.width - 20 : 780);
    }

    color: Style.backgroundColor
    height: 600
    minimumHeight: 450
    minimumWidth: 600
    title: qsTr("qterm")
    visible: true
    width: 800

    onClosing: close => {
        controller.shutdown();
        // controller.quitting()
        // close.accepted = true // If set to false, then the quit request will be ignored
    }

    MenuBar {
        id: menuBar

        Menu {
            id: fileMenu

            title: qsTr("File")

            MenuItem {
                id: aboutApp

                role: MenuItem.AboutRole
                text: "About..."
            }
            MenuItem {
                shortcut: StandardKey.ZoomIn
                text: qsTr("Zoom In")

                onTriggered: _ => {}
            }
            MenuItem {
                shortcut: StandardKey.ZoomOut
                text: qsTr("Zoom Out")

                onTriggered: _ => {}
            }
        }
    }
    ToolBar {
        id: toolBar

        width: calcWidth()

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
        }
    }
    TextView {
        id: textView

        width: calcWidth()

        anchors {
            bottom: prompt.top
            horizontalCenter: parent.horizontalCenter
            top: toolBar.bottom
        }
    }
    Prompt {
        id: prompt

        width: calcWidth()

        anchors {
            bottom: statusBar.top
            horizontalCenter: parent.horizontalCenter
        }
    }
    Item {
        id: statusBar

        height: 26
        width: calcWidth()

        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        Text {
            id: statusMessage

            anchors.top: statusBar.top
            color: Style.textColor
            font.pointSize: Style.h5
            text: qsTr("Serial comports not found")
            x: 20
        }
    }
    Connections {
        function onMessageReceived(message: string): void {
            textView.textArea.text += `${message}\n`;
            textView.scrollView.ScrollBar.vertical.position = 1.0 - textView.scrollView.ScrollBar.vertical.size;
        }
        function onStatusChanged(message: string): void {
            statusMessage.text = qsTr(message);
        }

        target: controller
    }
    Connections {
        function onMessageEntered(message: string): void {
            textView.textArea.text += `<b>${message}</b>\n`; // Add bold format to distinguish user input
        }

        target: prompt
    }
}
