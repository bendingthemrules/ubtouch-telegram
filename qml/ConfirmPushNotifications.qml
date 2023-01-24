import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import Lomiri.Layouts 1.0

Page {
    id: page
    width: parent.width
    height: parent.height
    anchors.fill: parent

    onVisibleChanged: {
        if (page.visible) { codeInput.forceActiveFocus() }
    }

    header: PageHeader {
        id: header
        title: i18n.tr('App Title')
        visible: false
    }

    Rectangle {
        id: confirmPopup
        color: "white"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: root.width * 0.85
        height: childrenRect.height + 48
        radius: 8

                ColumnLayout {
                    spacing: 8
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.margins: 12
                    anchors.topMargin: 24
                    anchors.bottomMargin: 24

                    Text {
                        id: name
                        Layout.fillWidth: true
                        text: "Authenticate by entering your code"
                        wrapMode: Text.WordWrap
                    }

                    Item { height: 24 } // spacer

                    Item {
                        Layout.fillWidth: true
                        implicitHeight: childrenRect.height - 6
                        clip: false

                        Rectangle {
                        id: rectangle
                        color: "#ffffff"
                        z: 2
                        x: 8
                        y: -6
                        width: phoneLabel.width + 8
                        height: 12

                            Label {
                                id: phoneLabel
                                Layout.fillWidth: true
                                color: "#707579"
                                text: "Auorization code"
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                font.weight: Font.Medium
                                font.pointSize: 10
                            }
                        }

                    TextInput {
                        id: codeInput
                        font.pointSize: 12
                        text: ""
                        mouseSelectionMode: TextInput.SelectWords
                        Layout.fillWidth: true
                        color: "#000000"
                        font.weight: Font.Medium
                        width: parent.width
                        focus: true

                        topPadding: 8
                        rightPadding: 12
                        bottomPadding: 8
                        leftPadding: 12

                        inputMethodHints: Qt.ImhDigitsOnly

                        layer.enabled: true
                        onEditingFinished: () => {
                            console.log("Text has changed to:", text)
                        }

                        Label {
                            color: "#707579"
                            text: "12345"
                            font.weight: Font.Medium
                            font.pointSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            visible: !codeInput.text
                        }

                        Rectangle {
                            z: -1
                            anchors.fill: parent
                            border.color: "#DADCE0"
                            border.width: 1
                            radius: 4
                            anchors.right: parent.right
                            anchors.left: parent.left
                        }
                    }
                }

                    Text {
                        Layout.fillWidth: true
                        color: "#9898B2"
                        text: "Enter the code you've received either on another device or through an SMS. An SMS could take up to 5 minutes."
                        wrapMode: Text.WordWrap
                        font.weight: Font.Medium
                        font.pointSize: 10
                    }

                    Item { height: 24 } // spacer

                    RowLayout {
                        Layout.fillWidth: true

                        Button {
                            implicitWidth: closeModal.width + 24
                            color: "#F3F2F7"
                            Layout.preferredHeight: closeModal.paintedHeight + 24
                            enabled: true
                            onClicked: {
                                QClient.cancelPushNotificationSetup()
                                pageStack.pop()
                            }

                            Label {
                                id: closeModal
                                text: "Cancel"
                                color: "#2B2937"
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        Item { Layout.fillWidth: true; }

                        Button {
                            implicitWidth: nextLabel.width + 24
                            color: "#3390EC"
                            Layout.preferredHeight: nextLabel.paintedHeight + 24
                            enabled: codeInput.text.length == 5
                            onClicked: {
                                QClient.enterCode(codeInput.text)
                                pageStack.pop()
                                pageStack.pop()
                            }

                            Label {
                                id: nextLabel
                                text: "Confirm"
                                color: "#ffffff"
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }
}
