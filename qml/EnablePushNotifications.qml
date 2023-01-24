import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import Lomiri.Layouts 1.0
import Lomiri.Components.Popups 1.3



Page {
    id: page
    width: parent.width
    height: parent.height
    anchors.fill: parent

    property var validatedPhoneNumber: false
    property var phoneRegex: /\+(9[976]\d|8[987530]\d|6[987]\d|5[90]\d|42\d|3[875]\d|2[98654321]\d|9[8543210]|8[6421]|6[6543210]|5[87654321]|4[987654310]|3[9643210]|2[70]|7|1)\d{1,14}$/
    
    onVisibleChanged: {
        if (page.visible) { phoneNumberInput.forceActiveFocus() }
    }

    header: PageHeader {
        id: header
        title: i18n.tr('App Title')
        visible: false
    }

    Rectangle {
                id: phonePopup
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
                        font.pointSize: 14
                        text: "To enable Telegram notifications, you have to authenticate this device."
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
                            text: "Phone number"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            font.weight: Font.Medium
                            font.pointSize: 10
                        }
                    }

                    TextInput {
                        id: phoneNumberInput
                        font.pointSize: 12
                        text: ""
                        mouseSelectionMode: TextInput.SelectWords
                        Layout.fillWidth: true
                        color: "#000000"
                        font.weight: Font.Medium
                        width: parent.width

                        topPadding: 8
                        rightPadding: 12
                        bottomPadding: 8
                        leftPadding: 12

                        inputMethodHints: Qt.ImhDialableCharactersOnly
                        clip: false
                        maximumLength: 20

                        layer.enabled: true
                        onEditingFinished: () => {
                            console.log("Text has changed to:", text)
                        }
                        onTextChanged: () => {
                            const match = phoneNumberInput.text.match(phoneRegex)
                            validatedPhoneNumber = !!match
                        }

                        Label {
                            color: "#707579"
                            text: "+2223334455"
                            font.weight: Font.Medium
                            font.pointSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            visible: !phoneNumberInput.text
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
                        text: "Please enter your number in international format"
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
                            enabled: validatedPhoneNumber
                            onClicked: {
                                  const match = phoneNumberInput.text.match(phoneRegex)
                                  if(!!match && validatedPhoneNumber){
                                    console.log("Match")
                                    QClient.enablePushNotifications(pushClient.token, phoneNumberInput.text)
                                    pageStack.push(Qt.resolvedUrl("ConfirmPushNotifications.qml"))
                                    return
                                  }
                                  PopupUtils.open(notificationDialog, root, {'errorResponse': "Invalid phone number"})
                            }

                            Label {
                                id: nextLabel
                                text: "Send code"
                                color: "#ffffff"
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }

            Component {
                id: notificationDialog
                
                Dialog {
                    id: dialog
                    property string errorResponse
                    text: errorResponse
                    title: "Failed to send code"
                    
                    Button {
                        text: "Continue"
                        onClicked: PopupUtils.close(dialog)
                    }
                }
            }
}
