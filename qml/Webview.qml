/*
 * Copyright (C) 2022  Development@bendingtherules.nl
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * matrix is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import Lomiri.PushNotifications 0.1
import QtWebEngine 1.10

Page {
    id: webview
    header: PageHeader {
       id: header
       title: i18n.tr('App Title')
       visible: false
    }

    property var checkedIsSetPushNotifications: false

    property WebEngineDownloadItem downloadItem
    property var downloadProgress: 0
    property var downloading: false
    property var downloadingBigFile: false

    property QtObject defaultProfile: WebEngineProfile {
        id: webContext
        downloadPath: QClient.appDir + "/Downloads/"

        onDownloadRequested: {
            QClient.clearDownloadsFolder()
            downloadItem = download
            download.accept()

            if (download.totalBytes > 10485760) {
                downloadingBigFile = true
            }

            downloading = true
        }

        onDownloadFinished: {
            var InstallPage = pageStack.push(
                                Qt.resolvedUrl("ExportPage.qml"),
                                {"contentUrl": download.path}
                            );

            downloading = false
            downloadingBigFile = false
            downloadProgress = 0
            downloadCompleteShowAni.start()
        }
    }

    Rectangle {
        id: downloadCompleteDialog
        color: "#bfb9b9b9"

        z: 5
        y: root.height + height
        height: downloadCompleteDialogText.implicitHeight + 24

        transformOrigin: Item.Top
        anchors.right: webview.right
        anchors.rightMargin: 16
        anchors.left: webview.left
        anchors.leftMargin: 16
        radius: 4

        Text {
            id: downloadCompleteDialogText
            text: `${downloadItem.mimeType.includes("image") || downloadItem.mimeType.includes("video") ? "Media" : "File"} saved to app Downloads.`
            font.weight: "Medium"
            wrapMode: Text.WordWrap
            anchors.fill: parent
            anchors.margins: 12
        }

        SequentialAnimation on y {
            id: downloadCompleteShowAni
            running: false
            NumberAnimation {from: -downloadCompleteDialog.height - 48; to: 62; duration: 1200; easing.type: Easing.InOutQuad}
            PauseAnimation {duration: 2000}
            NumberAnimation {from: 62; to: -downloadCompleteDialog.height - 48; duration: 1200; easing.type: Easing.InOutQuad}
        }
    }

    WebEngineView {
        id: webEngineView
        width: parent.width
        height: parent.height
        visible: false
        zoomFactor: 1
        anchors.fill: parent
        url: "https://webz.telegram.org"
        profile: defaultProfile
        settings.javascriptCanAccessClipboard: true
        userScripts: WebEngineScript {
            injectionPoint: WebEngineScript.DocumentReady
            sourceCode: `
                const css = 'html:focus-within {scroll-behavior: auto} *,*::before,*::after {animation-duration: 0.01ms !important;animation-iteration-count: 1 !important;transition-duration: 0.01ms !important';

                const head = document.head || document.getElementsByTagName('head')[0];
                const style = document.createElement('style');
                style.type = 'text/css';

                head.appendChild(style);
                style.appendChild(document.createTextNode(css));
            `
        }
        onLoadProgressChanged: {
            progressBar.value = loadProgress
            if (loadProgress === 100) {
                visible = true;
                if(url == "https://webz.telegram.org/" && !checkedIsSetPushNotifications && !QClient.cancelledPushNotificationSetup){
                    runJavaScript("
                     function checkIfLoggedIn() {
                        let isLoggedIn = false;
                        function check(){
                            if(!isLoggedIn){
                                l = document.querySelector('#LeftMainHeader');
                                if(!!l){
                                    isLoggedIn = true;
                                    window.location.href = 'https://webz.telegram.org/internal-user-logged-in';
                                };
                                setTimeout(check, 100);
                            };
                            return isLoggedIn;
                        };
                        check();
                    }; checkIfLoggedIn()");
                }
            }
        }
        onFeaturePermissionRequested: {
            webEngineView.grantFeaturePermission(securityOrigin, feature, true);
        }
        onNavigationRequested: (navigationRequest) => {
            console.log('Navigation requested ' + navigationRequest.url)
            if(navigationRequest.url.toString().includes("/internal-user-logged-in")){
                checkedIsSetPushNotifications = true
                navigationRequest.action = WebEngineNavigationRequest.IgnoreRequest
                let shouldEnablePushNotifications = QClient.shouldEnablePushNotifications(pushClient.token)
                console.log(shouldEnablePushNotifications)
                if(shouldEnablePushNotifications){
                    push(Qt.resolvedUrl("EnablePushNotifications.qml"))
                }
            }
        }
        onNewViewRequested: (request) => {
            Qt.openUrlExternally(request.requestedUrl);
        }
        onFileDialogRequested: function(request) {
            switch (request.mode)
            {
                case FileDialogRequest.FileModeOpen:
                    request.accepted = true;
                    var dialog = PopupUtils.open(Qt.resolvedUrl("FileDialog.qml"), this);
                    dialog.allowMultipleFiles = false;
                    dialog.accept.connect(request.dialogAccept);
                    dialog.reject.connect(request.dialogReject);
                    break;

                case FileDialogRequest.FileModeOpenMultiple:
                    request.accepted = true;
                    var dialog = PopupUtils.open(Qt.resolvedUrl("FileDialog.qml"), this);
                    dialog.allowMultipleFiles = true;
                    dialog.accept.connect(request.dialogAccept);
                    dialog.reject.connect(request.dialogReject);
                    break;

                case FilealogRequest.FileModeUploadFolder:
                case FileDialogRequest.FileModeSave:
                    request.accepted = false;
                    break;
            }
        }
    }

    Connections {
        target: UriHandler
        onOpened: {
            console.log("Open from Webview UriHandler", uris)

            if (uris.length > 0) {
                console.log("clicked push message while in app")
                const chatId = uris[0].split("#")[1]
                webEngineView.url = `https://webz.telegram.org/#${chatId}`
            }               
        }
    }

    Connections {
        target: Qt.inputMethod

        onKeyboardRectangleChanged: {
            var newRect = Qt.inputMethod.keyboardRectangle
            var scale = (newRect.y + newRect.height) / root.height

            webEngineView.height = newRect.height == 0
                ? root.height + 1
                : Math.ceil(newRect.y / scale);
        }
    }

    Rectangle {
        visible: !webEngineView.visible
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#38B0E3" }
            GradientStop { position: 1.0; color: "#1D93D2" }
        }
        anchors.fill: parent
    }

    Column {
        anchors.fill: parent
        visible: !webEngineView.visible
        
        Image {
            id: image
            width: 150
            height: 150
            anchors.centerIn: parent
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            source: "qrc:/assets/loader.svg"
        }
            
        ProgressBar {
            id: progressBar
            value: 0
            minimumValue: 0
            maximumValue: 100
            anchors.top: image.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 30
        }
    }
}
