import QtQuick
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root
    property bool active: false
    property bool busy: false
    readonly property string checkCmd: "systemctl --user is-active " + Plasmoid.metaData.pluginId + ".service"
    // This drives what shows in the panel (compact view)
    Plasmoid.icon: Qt.resolvedUrl(root.active ? "../icons/caffeine.svg" : "../icons/caffeine_inactive.svg")

    Timer {
        id: recheckTimer
        interval: 400
        repeat: false
        onTriggered: root.refresh()
    }

    Plasma5Support.DataSource {
        id: runner
        engine: "executable"
        connectedSources: []

        onNewData: (sourceName, data) => {
            disconnectSource(sourceName)

            if (sourceName === checkCmd) {
                const stdout = (data["stdout"] || "").toString().trim()
                root.active = (stdout === "active")
            } else {
                // A start/stop command just finished — re-check shortly after,
                // since systemd needs a moment to update unit state.
                root.busy = false
                recheckTimer.restart()
            }
        }

        function run(cmd) {
            disconnectSource(cmd)
            connectSource(cmd)
        }
    }


    function refresh() {
        runner.run(checkCmd)
    }

    function toggle() {
        if (busy) return
        busy = true
        if (root.active) {
            runner.run("systemctl --user stop " + Plasmoid.metaData.pluginId + ".service")
        } else {
            runner.run(
                "systemd-run --user --unit=" + Plasmoid.metaData.pluginId +
                " --collect --description='Caffeine: keep system awake' -- " +
                "systemd-inhibit --what=idle:sleep:handle-lid-switch " +
                "--who=Caffeine --why='Requested by user' --mode=block sleep infinity"
            )
        }
    }

    Component {
        id: content

        MouseArea {
            anchors.fill: parent
            onClicked: root.toggle()
            hoverEnabled: true

            Kirigami.Icon {
                anchors.fill: parent
                source: Qt.resolvedUrl(root.active ? "../icons/caffeine.svg" : "../icons/caffeine_inactive.svg")
                fallback: "view-refresh"

                opacity: (parent.containsMouse ? 1.25 : 1) * (root.busy ? 0.6 : (root.active ? 0.8 : 0.4))
                scale: parent.containsMouse ? 1.25 : 1.0

                Behavior on opacity { NumberAnimation { duration: 150 } }
                Behavior on scale { NumberAnimation { duration: 100 } }
            }
        }
    }

    compactRepresentation: Loader {
        sourceComponent: content
    }


    fullRepresentation: Loader {
        sourceComponent: content
    }
}
