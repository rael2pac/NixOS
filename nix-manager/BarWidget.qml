import QtQuick
import QtQuick.Layouts
import Noctalia

BarWidget {
    id: root
    
    Layout.preferredWidth: 32
    
    Icon {
        name: "distributor-logo-nixos"
        width: 20
        height: 20
        anchors.centerIn: parent
        color: root.hovered ? Color.primary : Color.text
    }
}
