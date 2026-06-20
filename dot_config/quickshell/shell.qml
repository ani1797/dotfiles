// shell.qml — Quickshell bar entry point
// Catppuccin Mocha theme, clean minimal design
// Panels: workspaces (left) | clock (center) | tray + resources (right)

import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

ShellRoot {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData
            height: 32
            anchors {
                top: true
                left: true
                right: true
            }
            color: "transparent"
            WlrLayershell.namespace: "quickshell:bar"
            WlrLayershell.exclusiveZone: 32

            // ── Background ──────────────────────────────────────────────────
            Rectangle {
                anchors.fill: parent
                color: "#1e1e2e"  // base

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 0

                    // ── Left: Workspace dots ─────────────────────────────────
                    RowLayout {
                        spacing: 6
                        Repeater {
                            model: HyprlandWorkspaces {}
                            delegate: Rectangle {
                                required property HyprlandWorkspace modelData
                                width: modelData.focused ? 18 : 8
                                height: 8
                                radius: 4
                                color: modelData.focused
                                    ? "#cba6f7"  // mauve — active
                                    : modelData.windows > 0
                                        ? "#585b70"  // surface2 — occupied
                                        : "#313244"  // surface0 — empty
                                Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: modelData.activate()
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }
                    }

                    // ── Center: Clock ────────────────────────────────────────
                    Item { Layout.fillWidth: true }
                    Text {
                        id: clock
                        color: "#cdd6f4"  // text
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: clock.text = Qt.formatDateTime(new Date(), "hh:mm  ddd d MMM")
                        }
                        Component.onCompleted: text = Qt.formatDateTime(new Date(), "hh:mm  ddd d MMM")
                    }
                    Item { Layout.fillWidth: true }

                    // ── Right: System tray + resources ───────────────────────
                    RowLayout {
                        spacing: 12

                        // Volume indicator
                        Text {
                            id: volumeText
                            color: "#89b4fa"  // blue
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            text: " 100%"
                        }

                        // System tray
                        RowLayout {
                            spacing: 4
                            Repeater {
                                model: SystemTray {}
                                delegate: Item {
                                    required property SystemTrayItem modelData
                                    width: 20
                                    height: 20
                                    Image {
                                        anchors.centerIn: parent
                                        source: modelData.icon
                                        width: 16
                                        height: 16
                                        smooth: true
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                                        onClicked: mouse.button === Qt.LeftButton
                                            ? modelData.activate()
                                            : modelData.secondaryActivate()
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
