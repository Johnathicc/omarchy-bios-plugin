import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "siob.power-actions"
  ipcTarget: "siob.power-actions"

  property int selectedIndex: 0
  property bool cursorActive: false
  property int pendingAction: -1

  readonly property var actions: [
    {
      icon: "󰐥",
      title: "Shut down",
      detail: "Power off this computer",
      prompt: "Shut down this computer now?",
      confirm: "Shut down",
      command: ["omarchy-system-shutdown"]
    },
    {
      icon: "󰜉",
      title: "Restart",
      detail: "Close applications and restart normally",
      prompt: "Restart this computer now?",
      confirm: "Restart",
      command: ["omarchy-system-reboot"]
    },
    {
      icon: "󰒓",
      title: "Restart to UEFI",
      detail: "Open firmware settings after restarting",
      prompt: "Restart into UEFI firmware settings now?",
      confirm: "Restart to UEFI",
      command: ["systemctl", "reboot", "--firmware-setup"]
    }
  ]

  function moveSelection(delta) {
    cursorActive = true
    selectedIndex = (selectedIndex + delta + actions.length) % actions.length
  }

  function requestAction(index) {
    if (index < 0 || index >= actions.length) return
    selectedIndex = index
    cursorActive = true
    pendingAction = index
    confirmDialog.selectedIndex = 0
  }

  function cancelAction() {
    pendingAction = -1
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function runAction() {
    if (pendingAction < 0 || pendingAction >= actions.length) return
    var command = actions[pendingAction].command
    pendingAction = -1
    close()
    Quickshell.execDetached(command)
  }

  onOpenedChanged: {
    if (opened) {
      selectedIndex = 0
      cursorActive = false
      pendingAction = -1
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰐥"
    slotSize: Style.bar.iconSlot
    tooltipText: "Power actions"
    onPressed: function(b) { if (b === Qt.LeftButton) root.toggle() }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(360))
    contentHeight: panel.fittedContentHeight(content.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: confirmDialog.opened
      onMoveRequested: function(dx, dy) {
        if (dy < 0 || dx < 0) root.moveSelection(-1)
        else if (dy > 0 || dx > 0) root.moveSelection(1)
      }
      onActivateRequested: {
        if (!root.cursorActive) root.cursorActive = true
        else root.requestAction(root.selectedIndex)
      }
      onCloseRequested: {
        if (confirmDialog.opened) root.cancelAction()
        else root.close()
      }
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(10)

        Text {
          width: parent.width
          text: "Power"
          color: root.bar ? root.bar.foreground : Color.foreground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.title
          font.bold: true
        }

        Text {
          width: parent.width
          text: "Choose what this computer should do."
          color: Qt.darker(root.bar ? root.bar.foreground : Color.foreground, 1.4)
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
        }

        PanelSeparator {
          width: parent.width
          foreground: root.bar ? root.bar.foreground : Color.foreground
        }

        Repeater {
          model: root.actions

          CursorSurface {
            required property var modelData
            required property int index

            width: content.width
            implicitHeight: Style.space(58)
            hasCursor: root.cursorActive && root.selectedIndex === index
            foreground: root.bar ? root.bar.foreground : Color.foreground
            accent: Color.accent

            Row {
              anchors.fill: parent
              anchors.leftMargin: Style.space(14)
              anchors.rightMargin: Style.space(14)
              spacing: Style.space(14)

              Text {
                width: Style.space(28)
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.icon
                color: index === 2 ? Color.accent : (root.bar ? root.bar.foreground : Color.foreground)
                font.family: root.bar ? root.bar.fontFamily : Style.font.family
                font.pixelSize: Style.font.iconLarge
                horizontalAlignment: Text.AlignHCenter
              }

              Column {
                width: parent.width - Style.space(42)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Style.space(2)

                Text {
                  width: parent.width
                  text: modelData.title
                  color: root.bar ? root.bar.foreground : Color.foreground
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: Style.font.body
                  font.weight: Font.Medium
                }

                Text {
                  width: parent.width
                  text: modelData.detail
                  color: Qt.darker(root.bar ? root.bar.foreground : Color.foreground, 1.4)
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: Style.font.caption
                  elide: Text.ElideRight
                }
              }
            }

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onEntered: {
                root.cursorActive = true
                root.selectedIndex = index
              }
              onClicked: root.requestAction(index)
            }
          }
        }
      }

      ConfirmDialog {
        id: confirmDialog
        anchors.fill: parent
        z: 10
        opened: root.pendingAction >= 0
        message: root.pendingAction >= 0 ? root.actions[root.pendingAction].prompt : ""
        confirmText: root.pendingAction >= 0 ? root.actions[root.pendingAction].confirm : "Confirm"
        background: Color.background
        foreground: root.bar ? root.bar.foreground : Color.foreground
        selectedText: Color.accent
        fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
        cornerRadius: Style.cornerRadius
        onCanceled: root.cancelAction()
        onConfirmed: root.runAction()
      }
    }
  }
}
