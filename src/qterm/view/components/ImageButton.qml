import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects // Dropped in Qt6
import Style

Rectangle {
    id: root
    width: 40
    height: 40
    radius: 5

    property int iconMargin: 16
    property alias iconSource: image.source
    property string description: ""
    property color backgroundColor: "transparent"
    property color hoverColor: Style.hoverColor
    property color iconColor: Style.iconColor

    color: backgroundColor

    signal clicked()

    signal mouseDown()

    signal mouseUp()

    // Force mouse area to recognize exited signal
    signal mouseAreaExited()

    onMouseAreaExited: () => mouseArea.exited()

    Image {
        id: image
        width: parent.width - iconMargin
        height: parent.height - iconMargin
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        visible: false // Hide image for overlay
        smooth: true
        antialiasing: true
        mipmap: false
        cache: false
    }

    ColorOverlay {
        anchors.fill: image
        source: image
        antialiasing: true
        opacity: root.enabled ? 0.9 : 0.4
        color: root.iconColor
    }

    ToolTip {
        id: toolTip
        visible: false
        x: Math.round(parent.width - width)
        y: Math.round(parent.height - height + 35)

        background: Rectangle {
            radius: Style.radius
            border.color: Style.borderColor
            color: Style.foregroundColor
            opacity: 0.7
        }

        contentItem: Text {
            id: toolTipText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            // style: Text.Sunken
            text: qsTr(description)
            font {
                pointSize: Style.h5
            }
            color: Style.toolTipTextColor
        }
    }

    MouseArea {
        id: mouseArea
        anchors {
            fill: parent
        }
        // cursorShape: Qt.PointingHandCursor
        hoverEnabled: root.enabled
        onEntered: {
            toolTip.visible = !!description
            root.color = hoverColor
        }
        onExited: {
            toolTip.visible = false
            root.color = backgroundColor
        }
        onClicked: {
            parent.clicked()
        }
        onPressed: () => parent.mouseDown()
        onReleased: () => parent.mouseUp()
    }
}
