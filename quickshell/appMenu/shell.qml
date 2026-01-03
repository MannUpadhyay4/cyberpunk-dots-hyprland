import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ShellRoot {
    LauncherWindow {}
}

PanelWindow {
    id: launcher
    visible: true
    width: 550
    height: 700
    color: "transparent"
    
    Rectangle {
        id: mainWindow
        anchors.fill: parent
        color: "#531f21a5"
        border.color: "#76f3fc"
        border.width: 2
        radius: 0
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8
                
                // Title bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    color: "transparent"
                    border.color: "#FF6E5A"
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: "RADIOPORT"
                        color: "#76f3fc"
                        font.family: "Orbitron"
                        font.bold: true
                        font.pixelSize: 11
                    }
                }
                
                // Player section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 116
                    color: "transparent"
                    
                    RowLayout {
                        anchors.fill: parent
                        spacing: 8
                        
                        // Album cover
                        Rectangle {
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 100
                            color: "#1a1a1acc"
                            border.color: "#FF6E5A"
                            border.width: 2
                            
                            Image {
                                anchors.fill: parent
                                source: "file://" + Qt.resolvedUrl("~/.config/rofi/assets/jhonny.png")
                                fillMode: Image.PreserveAspectFit
                            }
                        }
                        
                        // Song info
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"
                            border.color: "#FF6E5A"
                            border.width: 1
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 4
                                
                                Text {
                                    id: trackTitle
                                    Layout.fillWidth: true
                                    text: "NO TRACK PLAYING"
                                    color: "#FF6E5A"
                                    font.family: "Orbitron"
                                    font.bold: true
                                    font.pixelSize: 12
                                }
                                
                                Item {
                                    Layout.fillHeight: true
                                }
                                
                                // Volume row
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 12
                                    
                                    Text {
                                        text: "VOLUME"
                                        color: "#FF6E5A"
                                        font.family: "Orbitron"
                                        font.bold: true
                                        font.pixelSize: 12
                                    }
                                    
                                    Item {
                                        Layout.fillWidth: true
                                    }
                                    
                                    Rectangle {
                                        width: 30
                                        height: 24
                                        color: "#001a1acc"
                                        border.color: "#76f3fc"
                                        border.width: 1
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "A"
                                            color: "#76f3fc"
                                            font.family: "Orbitron"
                                            font.pixelSize: 10
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                // Volume up action
                                                Process.exec("bash", ["-c", "~/.config/rofi/spotify.sh control vol-up"])
                                            }
                                        }
                                    }
                                    
                                    Text {
                                        id: volumeText
                                        text: "00%"
                                        color: "#76f3fc"
                                        font.family: "Orbitron"
                                        font.bold: true
                                        font.pixelSize: 14
                                    }
                                    
                                    Rectangle {
                                        width: 30
                                        height: 24
                                        color: "#001a1acc"
                                        border.color: "#76f3fc"
                                        border.width: 1
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "D"
                                            color: "#76f3fc"
                                            font.family: "Orbitron"
                                            font.pixelSize: 10
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                // Volume down action
                                                Process.exec("bash", ["-c", "~/.config/rofi/spotify.sh control vol-down"])
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Search entry
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "#531f21a5"
                    border.color: "#76f3fc"
                    border.width: 1
                    
                    TextInput {
                        id: searchInput
                        anchors.fill: parent
                        anchors.margins: 8
                        color: "#76f5ffaa"
                        font.family: "Orbitron"
                        font.pixelSize: 12
                        verticalAlignment: TextInput.AlignVCenter
                        
                        Text {
                            visible: searchInput.text === ""
                            text: "Search stations..."
                            color: "#76f5ffaa"
                            font: searchInput.font
                            verticalAlignment: TextInput.AlignVCenter
                        }
                        
                        onTextChanged: {
                            appModel.filterText = text
                        }
                        
                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Escape) {
                                Global.launcherVisible = false
                            } else if (event.key === Qt.Key_Return) {
                                if (listView.currentIndex >= 0) {
                                    appModel.launchApp(listView.currentIndex)
                                    Global.launcherVisible = false
                                }
                            } else if (event.key === Qt.Key_Down) {
                                listView.currentIndex = Math.min(listView.currentIndex + 1, listView.count - 1)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Up) {
                                listView.currentIndex = Math.max(listView.currentIndex - 1, 0)
                                event.accepted = true
                            }
                        }
                    }
                }
                
                // List view
                ListView {
                    id: listView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 3
                    clip: true
                    focus: true
                    
                    model: ListModel {
                        id: appModel
                        property string filterText: ""
                        
                        function launchApp(index) {
                            var app = get(index)
                            Process.exec("bash", ["-c", app.exec])
                        }
                        
                        Component.onCompleted: {
                            // Load desktop entries
                            loadDesktopApps()
                        }
                        
                        function loadDesktopApps() {
                            // Parse .desktop files from /usr/share/applications
                            var proc = Process.exec("bash", ["-c", "ls /usr/share/applications/*.desktop 2>/dev/null"])
                            // This is simplified - you'd need to properly parse .desktop files
                            append({name: "Firefox", exec: "firefox"})
                            append({name: "Terminal", exec: "kitty"})
                            append({name: "File Manager", exec: "thunar"})
                            append({name: "VS Code", exec: "code"})
                            append({name: "Spotify", exec: "spotify"})
                        }
                    }
                    
                    delegate: Rectangle {
                        width: listView.width
                        height: 48
                        color: index % 2 === 0 ? "transparent" : "#1a1a1a88"
                        border.color: ListView.isCurrentItem ? "#76f3fc" : "transparent"
                        border.width: 1
                        
                        Rectangle {
                            anchors.fill: parent
                            color: ListView.isCurrentItem ? "#0a3a3acc" : "transparent"
                            
                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                verticalAlignment: Text.AlignVCenter
                                text: model.name
                                color: ListView.isCurrentItem ? "#76f3fc" : "#76f3fc"
                                font.family: "Orbitron"
                                font.bold: ListView.isCurrentItem
                                font.pixelSize: ListView.isCurrentItem ? 13 : 12
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            
                            onEntered: {
                                listView.currentIndex = index
                            }
                            
                            onClicked: {
                                appModel.launchApp(index)
                                Global.launcherVisible = false
                            }
                        }
                    }
                }
                
                // Mode switcher
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    color: "transparent"
                    border.color: "#76f3fc"
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 6
                        
                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 32
                            color: modeButtons.currentMode === "window" ? "#76f3fc" : "transparent"
                            border.color: "#76f3fc"
                            border.width: 1
                            
                            property bool selected: modeButtons.currentMode === "window"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "W"
                                color: parent.selected ? "#0a0a0a" : "#76f3fc"
                                font.family: "Orbitron"
                                font.bold: true
                                font.pixelSize: 11
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: modeButtons.currentMode = "window"
                            }
                        }
                        
                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 32
                            color: modeButtons.currentMode === "drun" ? "#76f3fc" : "transparent"
                            border.color: "#76f3fc"
                            border.width: 1
                            
                            property bool selected: modeButtons.currentMode === "drun"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "A"
                                color: parent.selected ? "#0a0a0a" : "#76f3fc"
                                font.family: "Orbitron"
                                font.bold: true
                                font.pixelSize: 11
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: modeButtons.currentMode = "drun"
                            }
                        }
                        
                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 32
                            color: modeButtons.currentMode === "file" ? "#76f3fc" : "transparent"
                            border.color: "#76f3fc"
                            border.width: 1
                            
                            property bool selected: modeButtons.currentMode === "file"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "F"
                                color: parent.selected ? "#0a0a0a" : "#76f3fc"
                                font.family: "Orbitron"
                                font.bold: true
                                font.pixelSize: 11
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: modeButtons.currentMode = "file"
                            }
                        }
                        
                        Item {
                            Layout.fillWidth: true
                        }
                    }
                    
                    QtObject {
                        id: modeButtons
                        property string currentMode: "drun"
                    }
                }
            }
        }
    }
    
    Component.onCompleted: {
        searchInput.forceActiveFocus()
    }
}
