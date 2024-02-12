// noinspection JSValidateTypes

import QtQuick
import TextInput
import "qrc:/appstates.js" as AppStates

Item {
    id: root

    signal messageEntered(string message)

    height: 60
    state: AppStates.states.Closed

    states: [
        State {
            name: AppStates.states.Closed

            PropertyChanges {
                enabled: false
                target: root
            }
        },
        State {
            name: AppStates.states.Opened

            PropertyChanges {
                enabled: true
                target: root
            }
        }
    ]

    TextInput {
        id: input

        anchors.centerIn: parent
        width: parent.width

        Keys.onReturnPressed: _ => {
            controller.forwardMessage(text);
            messageEntered(text);
            clear();
        }
    }
    Connections {
        function onDeviceClosed(): void {
            root.state = AppStates.states.Closed;
        }
        function onDeviceOpened(): void {
            root.state = AppStates.states.Opened;
        }

        target: controller
    }
}
