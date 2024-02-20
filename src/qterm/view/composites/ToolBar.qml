// noinspection JSUnresolvedReference,JSValidateTypes

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DropDown
import TextInput
import ImageButton
import Style
import "qrc:/appstates.js" as AppStates

Item {
    id: root

    function validateInputs() {
        button.enabled = !!(ports.currentText !== "" && baudrate.acceptableInput && delimiter.text !== "");
    }

    height: 100

    RowLayout {
        id: controls

        anchors.verticalCenter: parent.verticalCenter
        enabled: machine.hasClosedState
        spacing: 20
        x: 20

        ColumnLayout {
            spacing: 5

            Label {
                color: Style.textColor
                text: "Ports"

                font {
                    pointSize: Style.h4
                    weight: Font.Normal
                }
            }
            DropDown {
                id: ports

                enabled: controls.enabled && model.length > 0
                implicitWidth: 200
                model: controller.model

                onCurrentTextChanged: _ => validateInputs()
            }
        }
        ColumnLayout {
            spacing: 5

            Label {
                color: Style.textColor
                text: "Baudrate"

                font {
                    pointSize: Style.h4
                    weight: Font.Normal
                }
            }
            TextInput {
                id: baudrate

                enabled: controls.enabled && ports.model.length > 0
                placeholder: qsTr("115200")
                text: qsTr("115200")

                validator: IntValidator {
                }

                onTextChanged: _ => validateInputs()
            }
        }
        ColumnLayout {
            spacing: 5

            Label {
                color: Style.textColor
                text: "Delimiter"

                font {
                    pointSize: Style.h4
                    weight: Font.Normal
                }
            }
            TextInput {
                id: delimiter

                enabled: controls.enabled && ports.model.length > 0
                placeholder: qsTr("\\n")
                text: qsTr("\\n")

                onTextChanged: _ => validateInputs()
            }
        }
    }
    ImageButton {
        id: button

        anchors.verticalCenter: parent.verticalCenter
        description: machine.hasOpenState ? "Close device" : "Open device"
        enabled: false
        iconColor: machine.hasOpenState ? "#e63946" : "#8ac926"
        iconSource: machine.hasOpenState ? "qrc:/image/stop" : "qrc:/image/play"
        x: parent.width - width - 20

        onClicked: machine.hasOpenState ? controller.closeSerialDevice() : controller.connectSerialDevice(ports.currentText.split(':', 1), parseInt(baudrate.text), delimiter.text.replace(/\\r/g, '\r').replace(/\\n/g, '\n'))
    }
}
