import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Repeater {
  model: 10

  Text {
    property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
    property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
    text: index + 1
    color: isActive ? "blue" : (ws ? "lightblue" : "grey")
    font { pixelSize: 18; bold: true }

    MouseArea {
      anchors.fill: parent
      onClicked: Hyprland.dispatch("workspace " + (index + 1))
    }
  }
}

