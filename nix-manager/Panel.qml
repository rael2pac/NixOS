import QtQuick
import QtQuick.Layouts
import Noctalia

Panel {
    id: root
    width: 250
    height: 180
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Label {
            text: "NixOS Manager"
            font.bold: true
            font.pointSize: 12
            Layout.alignment: Qt.AlignHCenter
        }

        Button {
            text: "Atualizar Sistema"
            icon: "view-refresh"
            Layout.fillWidth: true
            onClicked: {
                // Roda o seu alias 'update' em um terminal kitty
                App.spawn("kitty -e bash -c 'update; echo; echo Concluido! Pressione Enter para fechar; read'")
                root.close()
            }
        }

        Button {
            text: "Limpeza Completa"
            icon: "edit-clear-all"
            Layout.fillWidth: true
            onClicked: {
                // Roda o seu alias 'clean' em um terminal kitty
                App.spawn("kitty -e bash -c 'clean; echo; echo Concluido! Pressione Enter para fechar; read'")
                root.close()
            }
        }
        
        Label {
            text: "Mantém 2 gerações de backup"
            font.pointSize: 8
            opacity: 0.6
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
