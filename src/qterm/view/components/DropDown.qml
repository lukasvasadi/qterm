import QtQuick
import QtQuick.Controls
import Style

ComboBox {
    id: root

    implicitHeight: 40
    implicitWidth: 120

    background: Rectangle {
        color: "#999"
        implicitHeight: parent.implicitHeight
        implicitWidth: parent.implicitWidth
        radius: Style.radius
    }
    contentItem: Text {
        color: "#222"
        elide: Text.ElideRight
        font: parent.font
        leftPadding: 10
        text: parent.displayText
        verticalAlignment: Text.AlignVCenter
    }
    delegate: ItemDelegate {
        id: delegate

        required property int index
        required property var model

        hoverEnabled: true
        width: root.width + 90

        background: Rectangle {
            anchors.fill: parent
            color: delegate.hovered ? "#ccc" : "transparent"
            radius: Style.radius
        }
        contentItem: Text {
            anchors.verticalCenter: parent.verticalCenter
            color: "#222"
            leftPadding: 10
            opacity: 0.9
            text: delegate.model[root.textRole]
        }
    }
    indicator: Canvas {
        id: canvas

        contextType: "2d"
        height: 8
        width: 12
        x: root.width - width - root.rightPadding
        y: root.topPadding + (root.availableHeight - height) / 2

        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = root.pressed ? "#333" : "#333";
            context.fill();
        }

        Connections {
            function onPressedChanged() {
                canvas.requestPaint();
            }

            target: root
        }
    }
    popup: Popup {
        id: popup

        implicitHeight: contentItem.implicitHeight + 10
        padding: 5
        width: parent.width + 100
        y: parent.height + 10

        background: Rectangle {
            border.color: Style.borderColor
            color: "#aaa"
            radius: Style.radius
        }
        contentItem: ListView {
            clip: true
            currentIndex: root.highlightedIndex
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null

            ScrollIndicator.vertical: ScrollIndicator {
            }
        }
    }
}
