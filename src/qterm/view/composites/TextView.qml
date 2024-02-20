// noinspection JSValidateTypes

import QtQuick
import QtQuick.Controls
import Style
import "qrc:/appstates.js" as AppStates

Item {
    id: root

    property alias scrollView: scrollView
    property alias textArea: textArea

    enabled: machine.hasOpenState

    ScrollView {
        id: scrollView

        anchors.fill: parent

        background: Rectangle {
            color: Style.foregroundColor
            radius: Style.radius
        }

        TextArea {
            id: textArea

            color: Style.textColor
            padding: 10
            readOnly: true
            selectionColor: Style.selectionColor
            textFormat: TextEdit.RichText

            font {
                pointSize: Style.h4
            }
        }
    }
    DropArea {
        id: dropArea

        anchors.fill: scrollView

        onDropped: drop => {
            drop.accept();
            controller.transferTextFile(drop.urls[0]);
        }
        onEntered: _ => {
            dropRect.border.color = Style.activeColor;
        }
        onExited: _ => {}

        Rectangle {
            id: dropRect

            anchors.fill: parent
            border.color: "transparent"
            border.width: 2
            color: "transparent"
            radius: Style.radius
            visible: parent.containsDrag
        }
    }
    Connections {
        function onDeviceClosed(): void {
            textArea.clear();
        }
        function onFileDataProcessed(data: string): void {
            textArea.text += `<b>${data}</b>`;
        }

        target: controller
    }
}

