import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Quickshell.Io


Scope {
  id: root
  Variants {
    model: Quickshell.screens
    PanelWindow {
      required property var modelData
      screen: modelData

      property int cpuUsage: 0
      property int memUsage: 0
      property int gpuUsage: 0
      property var lastCpuIdle: 0
      property var lastCpuTotal: 0
      
      Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
          onRead: data => {
            if (!data) return
            var p = data.trim().split(/\s+/)
            var idle = parseInt(p[4]) + parseInt(p[5])
            var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
            if (lastCpuTotal > 0) {
              cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)))
            }
            lastCpuTotal = total
            lastCpuIdle = idle
          }
        }
      }

      Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
          onRead: data => {
            if (!data) return
            var parts = data.trim().split(/\s+/)
            var total = parseInt(parts[1]) || 1
            var used = parseInt(parts[2]) || 0
            memUsage = Math.round(100 * used / total)
          }
        }
        Component.onCompleted: running = true
      }

      Process{
        id: gpuProc
        command: ["sh", "-c", "cat /sys/class/hwmon/hwmon0/device/gpu_busy_percent"]
        stdout: SplitParser {
          onRead: data => {
            if (!data) return
            gpuUsage = parseInt(data)
          }
        }
      }

      Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
          cpuProc.running = true
          memProc.running = true
          gpuProc.running = true
        }
      }

      anchors.top: true
      anchors.left: true
      anchors.right: true
      implicitHeight: 30
      color: "white"

      RowLayout {
        anchors.fill: parent
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 8
        anchors.rightMargin: 8

        Workspaces {}

        Item { Layout.fillWidth: true }

        Text {
          text: "CPU: " + cpuUsage + "%"
          color: "grey"
          font { pixelSize: 18; bold: true }
        }

        Text {
          text: "GPU: " + gpuUsage + "%"
          color: "grey"
          font { pixelSize: 18; bold: true }
        }

        Text {
          text: "Mem: " + memUsage + "%"
          color: "grey"
          font { pixelSize: 18; bold: true }
        }
      }
    }
  }
}
