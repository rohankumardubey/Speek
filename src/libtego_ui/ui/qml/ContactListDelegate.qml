import QtQuick 2.0
import QtQuick.Controls 1.0
import im.ricochet 1.0
import QtQuick.Layouts 1.0
import QtQuick.Controls.Styles 1.2

Rectangle {
    id: delegate
    //color: highlighted ? "#c4e7ff" : palette.base
    color: ma.containsMouse ? highlighted ? Qt.lighter(palette.highlight, 0.9): styleHelper.contactListHover : highlighted ? palette.highlight : palette.base
    width: parent != null ? parent.width : 0
    height: search_visible() ? 55 : 0
    visible: search_visible()

    function search_visible(){
        if(typeof(searchUserText) === "undefined")
            return true
        else if(searchUserText === "")
            return true
        else if(model.contact.nickname.toLowerCase().indexOf(searchUserText.toLowerCase()) !== -1)
            return true
        else
            return false
    }

    property bool highlighted: ListView.isCurrentItem
    onHighlightedChanged: {
        if (renameMode)
            renameMode = false
    }
    RowLayout{
        id: rowContact
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        height:55
        Rectangle{
            width:3
            color:"transparent"
        }
        ColorLetterCircle{
            name: model.name !== "" ? model.name : "-"
            icon: typeof(model.contact.icon) !== "undefined" ? model.contact.icon : ""
        }
        ColumnLayout{
            spacing:0
            Label {
                id: nameLabel
                anchors {
                    leftMargin: 6
                    rightMargin: 8
                    topMargin: 15
                }
                text: model.name
                textFormat: Text.PlainText
                elide: Text.ElideRight
                Layout.preferredWidth: delegate.width - 70
                font.pointSize: styleHelper.pointSize * 0.9
                font.bold: true
                color: palette.text
            }
            Label {
                anchors.bottomMargin: 15
                text: model.status === ContactUser.Online ? "online": "offline"
                textFormat: Text.PlainText
                font.pointSize: styleHelper.pointSize *0.8
                color: palette.text
                //opacity: model.status === ContactUser.Online ? 1 : 0.8
                opacity: 0.6
            }
        }
    }

    UnreadCountBadge {
        id: unreadBadge
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 8
        }

        value: model.contact.conversation.unreadCount
    }

    ContactActions {
        id: contextMenu
        contact: model.contact

        onRenameTriggered: renameMode = true
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true

        onPressed: {
            if (!delegate.ListView.isCurrentItem)
                //if(model.status !== ContactUser.RequestPending)
                    contactListView.currentIndex = model.index
        }

        onClicked: {
            if (mouse.button === Qt.RightButton) {
                contextMenu.openContextMenu()
            }
        }

        onDoubleClicked: {
            if (mouse.button === Qt.LeftButton) {
                contactListView.contactActivated(model.contact, contextMenu)
            }
        }
    }

    property bool renameMode
    property Item renameItem
    onRenameModeChanged: {
        if (renameMode && renameItem === null) {
            renameItem = renameComponent.createObject(delegate)
            renameItem.forceActiveFocus()
            renameItem.selectAll()
        } else if (!renameMode && renameItem !== null) {
            renameItem.visible = false
            renameItem.destroy()
            renameItem = null
        }
    }

    Component {
        id: renameComponent

        TextField {
            width: 150
            id: nameField
            anchors {
                horizontalCenter: rowContact.horizontalCenter
            }
            text: model.contact.nickname
            onAccepted: {
                model.contact.nickname = text
                delegate.renameMode = false
            }
        }
    }
}

