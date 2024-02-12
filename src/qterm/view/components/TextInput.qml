import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Style

TextField {
    id: control

    property string placeholder: ""

    color: Style.textColor
    implicitHeight: 40
    implicitWidth: 120
    placeholderText: qsTr(placeholder)
    placeholderTextColor: Style.placeholderTextColor
    selectedTextColor: Style.selectionTextColor
    selectionColor: Style.selectionColor

    background: Rectangle {
        color: Style.foregroundColor
        implicitHeight: control.implicitHeight
        implicitWidth: control.implicitWidth
        opacity: control.enabled ? 1.0 : 0.4
        radius: Style.radius

        border {
            color: control.activeFocus ? Style.activeColor : Style.borderColor
            width: control.activeFocus ? 2 : 1
        }
    }

    font {
        pointSize: Style.h5
    }
}
