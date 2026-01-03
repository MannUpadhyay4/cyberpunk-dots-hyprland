import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick
import Quickshell.Hyprland

PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 60
    color: "transparent"

    property int ramSegments: 20
    property real cpuTemp: 0

    Process {
        id: ramProc
        command: ["sh", "-c", "free | grep Mem | awk '{print $3/$2 * 100.0}'"]
        running: true
        property real ramUsage: 0
        stdout: StdioCollector { onStreamFinished: ramProc.ramUsage = parseFloat(this.text.trim()) || 0 }
    }

    Process {
        id: cpuTempProc
        command: ["sh", "-c", "sensors -u | awk '/temp1_input/ {print $2; exit}'"]
        running: true
        stdout: StdioCollector { onStreamFinished: cpuTemp = parseFloat(this.text.trim()) || 0 }
    }
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            ramProc.running = true
            cpuTempProc.running = true
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#20000000"
    }

    Item {
        id: workspaceBar
        width: 550
        height: 40
        anchors.centerIn: parent

        Row {
            anchors.centerIn: parent
            spacing: 4

            Rectangle {
                width: 30
                height: 24
                color: "transparent"
                border.color: "#5EF6FF"
                border.width: 1
                radius: 2
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    font.pixelSize: 12
                    font.family: "JetBrainsMono Nerd Font Propo"
                    text: "\ueb6f"
                    color: "#5EF6FF"
                }
            }

            Repeater {
                model: 9 

                Rectangle {
                    property int workspaceIndex: index
                    property bool isActive: Hyprland.focusedWorkspace.id === (workspaceIndex + 1)
                    width: 24
                    height: 24
                    color: "transparent"
                    radius: 2

                    Text {
                        anchors.centerIn: parent
                        text: parent.workspaceIndex + 1
                        color: parent.isActive ? "#5EF6FF" : "#FF6E5A"
                        font.pixelSize: 12
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font Propo"
                    }

                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: 2
                        color: parent.isActive ? "#5EF6FF" : "#FF6E5A"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("workspace " + (parent.workspaceIndex + 1))
                    }
                }
            }

            Rectangle {
                width: 30
                height: 24
                color: "transparent"
                border.color: "#5EF6FF"
                border.width: 1
                radius: 2
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    font.pixelSize: 12
                    font.family: "JetBrainsMono Nerd Font Propo"
                    text: "\ueb70"
                    color: "#5EF6FF"
                }
            }
        }
    }

    Item {
        width: 150
        height: 60
        anchors.right: parent.right
        anchors.rightMargin: 40 
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 8
            font.pixelSize: 20
            font.bold: true
            color: "#5EF6FF"

            Process {
                id: timeProc
                command: ["date", "+%H:%M:%S"]
                running: true
                stdout: StdioCollector { onStreamFinished: clock.text = this.text.trim() }
            }
        }

        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: clock.bottom
            anchors.topMargin: -2
            font.pixelSize: 10
            color: "#888888"

            Process {
                id: dateProc
                command: ["date", "+2077.%m.%d"]
                running: true
                stdout: StdioCollector { onStreamFinished: dateText.text = this.text.trim() }
            }
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: { 
                timeProc.running = true
                dateProc.running = true 
            }
        }
    }

    Item {
        width: 580
        height: 60
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 15

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Item {
                width: 60
                height: 60

                Image {
                    anchors.fill: parent
                    source: "./assets/Battery_level.svg"
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: 60
                    sourceSize.height: 60
                }

                Text {
                    anchors.centerIn: parent
                    color: "#5EF6FF"
                    font.pixelSize: 12
                    font.bold: true
                    text: Math.round(UPower.displayDevice.percentage * 100) + "%"
                }
            }

            Item {
                id: barsContainer
                width: 420
                height: 45
                anchors.top: parent.top
                anchors.topMargin: 10
                Column {
                    anchors.fill: parent
                    spacing: 3
                    Item {
                        id: cpuTempBarContainer
                        width: parent.width
                        height: 14

                        Rectangle {
                            anchors.fill: parent
                            color: "#1a0000"
                            border.color: "#FF6E5A"
                            border.width: 1
                            radius: 2
                        }

                        Rectangle {
                            id: cpuHpBar
                            height: parent.height - 2
                            width: Math.max(2, (parent.width - 2) * Math.max(0, 1 - cpuTemp / 120))
                            anchors.left: parent.left
                            anchors.leftMargin: 1
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#FF6E5A"
                            radius: 1
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#FF6E5A"
                            font.pixelSize: 8
                            font.bold: true
                            text: "CPU " + Math.ceil(cpuTemp) + "°C"
                        }
                    }

                    Item {
                        id: ramBarContainer
                        width: parent.width
                        height: 16

                        Rectangle {
                            anchors.fill: parent
                            color: "#001a1a"
                            border.color: "#5EF6FF"
                            border.width: 1
                            radius: 1
                        }

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 2
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            property int totalSegments: ramSegments
                            property int filledSegments: Math.floor((ramProc.ramUsage / 100) * totalSegments)

                            Repeater {
                                model: ramSegments
                                Rectangle {
                                    width: Math.floor((ramBarContainer.width - 4 - (ramSegments - 1)) / ramSegments)
                                    height: ramBarContainer.height - 4
                                    color: index < parent.filledSegments ? "#5EF6FF" : "transparent"
                                }
                            }
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#5EF6FF"
                            font.pixelSize: 7
                            font.bold: true
                            text: "RAM " + Math.round(ramProc.ramUsage) + "%"
                        }
                      }
                }
            }

        }
    }
}
