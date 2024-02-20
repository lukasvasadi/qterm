// noinspection JSValidateTypes

import QtQuick
import TextInput
import "qrc:/appstates.js" as AppStates

Item {
    id: root

    signal messageEntered(string message)

    enabled: machine.hasOpenState
    height: 60

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
}
