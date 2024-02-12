// noinspection JSValidateTypes

pragma Singleton
import QtQuick

QtObject {
    readonly property color accentColor: "#c678dd"
    readonly property color activeColor: "#4361ee"
    readonly property color backgroundColor: "#232429"
    readonly property color borderColor: "#464a53"
    readonly property color foregroundColor: "#333742"
    readonly property int h4: {
        switch (Qt.platform.os) {
        case "windows":
            return 14;
        case "osx":
            return 16;
        default:
            return 14;
        }
    }
    readonly property int h5: {
        switch (Qt.platform.os) {
        case "windows":
            return 12;
        case "osx":
            return 14;
        default:
            return 12;
        }
    }
    readonly property color hoverColor: "#414855"
    readonly property color iconColor: "#b3b3b3"
    readonly property color placeholderTextColor: "#aaa"
    readonly property int radius: 5
    readonly property color selectionColor: "#98c379"
    readonly property color selectionTextColor: "#eee"
    readonly property color textColor: "#ccc"
    readonly property color textColorBright: "#eee"
    readonly property color toolTipColor: "#333742"
    readonly property color toolTipTextColor: "#bbb"
}
