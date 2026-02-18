import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: "#1a1b26"

    property string fontFamily: "JetBrainsMono Nerd Font"

    // ── Clock ───────────────────────────────────────────
    Text {
        id: clock
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.15
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: root.fontFamily
        font.pixelSize: 72
        font.weight: Font.Light
        color: "#c0caf5"
        text: Qt.formatTime(new Date(), "HH:mm")

        Timer {
            interval: 30000
            running: true
            repeat: true
            onTriggered: clock.text = Qt.formatTime(new Date(), "HH:mm")
        }
    }

    Text {
        id: dateText
        anchors.top: clock.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: root.fontFamily
        font.pixelSize: 16
        color: "#565f89"
        text: Qt.formatDate(new Date(), "dddd, MMMM d")

        Timer {
            interval: 60000
            running: true
            repeat: true
            onTriggered: dateText.text = Qt.formatDate(new Date(), "dddd, MMMM d")
        }
    }

    // ── Login Form ──────────────────────────────────────
    Column {
        id: loginForm
        anchors.centerIn: parent
        spacing: 16
        width: 320

        // Username field
        TextField {
            id: userField
            width: parent.width
            height: 44
            placeholderText: "Username"
            text: userModel.lastUser
            font.family: root.fontFamily
            font.pixelSize: 14
            color: "#c0caf5"
            horizontalAlignment: TextInput.AlignHCenter

            background: Rectangle {
                color: "#24283b"
                radius: 22
                border.color: userField.activeFocus ? "#7aa2f7" : "#565f89"
                border.width: 2

                Behavior on border.color {
                    ColorAnimation { duration: 200 }
                }
            }

            Keys.onTabPressed: passwordField.forceActiveFocus()
            Keys.onReturnPressed: sddm.login(userField.text, passwordField.text, sessionModel.lastIndex)
        }

        // Password field
        TextField {
            id: passwordField
            width: parent.width
            height: 44
            placeholderText: "Password"
            echoMode: TextInput.Password
            font.family: root.fontFamily
            font.pixelSize: 14
            color: "#c0caf5"
            horizontalAlignment: TextInput.AlignHCenter

            background: Rectangle {
                color: "#24283b"
                radius: 22
                border.color: passwordField.activeFocus ? "#7aa2f7" : "#565f89"
                border.width: 2

                Behavior on border.color {
                    ColorAnimation { duration: 200 }
                }
            }

            Keys.onReturnPressed: sddm.login(userField.text, passwordField.text, sessionModel.lastIndex)
        }

        // Error message
        Text {
            id: errorMsg
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.family: root.fontFamily
            font.pixelSize: 12
            color: "#f7768e"
            text: ""
            visible: text !== ""
        }
    }

    // ── Power Buttons ───────────────────────────────────
    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 16

        // Reboot pill
        Rectangle {
            width: 100
            height: 36
            radius: 18
            color: rebootMouse.containsMouse ? "#292e42" : "#24283b"
            border.color: rebootMouse.containsMouse ? "#7aa2f7" : "#565f89"
            border.width: 1

            Behavior on color { ColorAnimation { duration: 200 } }
            Behavior on border.color { ColorAnimation { duration: 200 } }

            Text {
                anchors.centerIn: parent
                text: "  Reboot"
                font.family: root.fontFamily
                font.pixelSize: 13
                color: "#c0caf5"
            }

            MouseArea {
                id: rebootMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: sddm.reboot()
                cursorShape: Qt.PointingHandCursor
            }
        }

        // Shutdown pill
        Rectangle {
            width: 110
            height: 36
            radius: 18
            color: shutdownMouse.containsMouse ? "#292e42" : "#24283b"
            border.color: shutdownMouse.containsMouse ? "#f7768e" : "#565f89"
            border.width: 1

            Behavior on color { ColorAnimation { duration: 200 } }
            Behavior on border.color { ColorAnimation { duration: 200 } }

            Text {
                anchors.centerIn: parent
                text: "  Shutdown"
                font.family: root.fontFamily
                font.pixelSize: 13
                color: "#c0caf5"
            }

            MouseArea {
                id: shutdownMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: sddm.powerOff()
                cursorShape: Qt.PointingHandCursor
            }
        }
    }

    // ── SDDM Connections ────────────────────────────────
    Connections {
        target: sddm
        function onLoginFailed() {
            passwordField.text = ""
            errorMsg.text = "Login failed"
            passwordField.forceActiveFocus()
        }
        function onLoginSucceeded() {
            errorMsg.text = ""
        }
    }

    Component.onCompleted: {
        if (userField.text !== "") {
            passwordField.forceActiveFocus()
        } else {
            userField.forceActiveFocus()
        }
    }
}
