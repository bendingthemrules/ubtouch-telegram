
import QtQuick 2.7
import QtWebEngine 1.7
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3 as Popups
import Lomiri.Content 1.3
import "."

Popups.PopupBase {
    id: picker
    objectName: "contentPickerDialog"


    property var activeTransfer
    property bool allowMultipleFiles

    signal accept(var files)
    signal reject()

    onAccept: hide()
    onReject: hide()

    Rectangle {
      anchors.fill: parent

      ContentTransferHint {
          anchors.fill: parent
          activeTransfer: picker.activeTransfer
      }

      ContentPeerPicker {
          id: peerPicker
          anchors.fill: parent
          visible: true
          contentType: ContentType.All
          handler: ContentHandler.Source

          onPeerSelected: {
            if (allowMultipleFiles) {
                peer.selectionType = ContentTransfer.Multiple
            } else {
                peer.selectionType = ContentTransfer.Single
            }
            picker.activeTransfer = peer.request()
            stateChangeConnection.target = picker.activeTransfer
          }

          onCancelPressed: {
              reject()
          }
      }
  }

  Connections {
      id: stateChangeConnection
      target: null
      onStateChanged: {
          if (picker.activeTransfer.state === ContentTransfer.Charged) {
              var selectedItems = []
              for(var i in picker.activeTransfer.items) {
                  
                  // ContentTransfer.Single seems not to be handled properly, e.g. selected items with file manager
                  // -> only select the first item
                  if ((i > 0) && ! allowMultipleFiles)
                  {
                      break;
                  }
                  
                  selectedItems.push(String(picker.activeTransfer.items[i].url).replace("file://", ""))
              }
              accept(selectedItems)
          }
      }
  }

  Component.onCompleted: {
      peerPicker.contentType = ContentType.All
      show()
  }
}
