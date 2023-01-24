import QtQuick 2.9
import QtQuick.Controls 2.2
import Lomiri.Components 1.3
import Lomiri.Content 1.3

Page {
    id: picker

    Component {
        id: resultComponent
        ContentItem {}
    }

    header: PageHeader {
       id: header
       title: i18n.tr('Open with')
    }

    visible: false
    property var contentUrl
    property var curTransfer

    function __exportItems(url) {
        console.log("__ExportingItems")
        if (picker.curTransfer.state === ContentTransfer.InProgress)
        {
            picker.curTransfer.items = [ resultComponent.createObject(parent, {"url": Qt.resolvedUrl("file://" + url)}) ];
            picker.curTransfer.state = ContentTransfer.Charged;
        }
    }

    ContentPeerPicker {
        anchors {
            fill: parent
            topMargin: picker.header.height
        }

        visible: parent.visible
        showTitle: false
        contentType: ContentType.All
        handler: ContentHandler.Destination

        onPeerSelected: {
            picker.curTransfer = peer.request();
            if (picker.curTransfer.state === ContentTransfer.InProgress)
                picker.__exportItems(picker.contentUrl);

            pageStack.pop()
        }

        onCancelPressed: {
            pageStack.pop()
        }
    }

    Connections {
        target: picker.curTransfer
        onStateChanged: {
            if (picker.curTransfer.state === ContentTransfer.InProgress) {
                picker.__exportItems(picker.contentUrl);
            }
        }
    }
}
