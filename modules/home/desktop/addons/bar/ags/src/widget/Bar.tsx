import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable } from "astal"

const time = Variable("").poll(1000, "date")

export default function Bar(gdkmonitor: Gdk.Monitor) {
    return <window
        className="Bar"
        gdkmonitor={gdkmonitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={Astal.WindowAnchor.TOP
            | Astal.WindowAnchor.LEFT
            | Astal.WindowAnchor.RIGHT}
        application={App}>
        <centerbox>
            <button
                onClicked="echo hello"
                halign={Gtk.Align.CENTER} >
                Welcome to AGS!
            </button>
            <box />
            <button
                onClick={() => print("hello")}
                halign={Gtk.Align.CENTER} >
                <label label={time()} />
            </button>
        </centerbox>
    </window>
}


import { RightSide } from "right_side"


const hyprland = await Service.import("hyprland")

function Workspaces(monitor_id: number) {
    const workspaces = Array.from({length: 10}, (_, index) => {
        const id = index + 1
        return Widget.Button({
            on_clicked: () => hyprland.messageAsync(
                `dispatch focusworkspaceoncurrentmonitor ${id}`
            ),

            child: Widget.Label({
                label: id.toString(),
                class_name: Utils.merge(
                    [
                        hyprland.bind("workspaces"), 
                        hyprland.bind("monitors"),
                    ],
                    (workspaces, monitors) => {
                        const workspace_type = (() => {
                            if (id === monitors[monitor_id].activeWorkspace.id) {
                                return "current"
                            }
                            
                            if (
                                monitors.map((monitor) => 
                                    monitor.activeWorkspace.id
                                ).includes(id)
                            ) {
                                return "focused"
                            }
                            
                            if (
                                workspaces.map((workspace) => 
                                    workspace.id
                                ).includes(id)
                            ) {
                                return "active"
                            }

                            return "inactive"
                        })()

                        return `workspace workspace_${workspace_type}`
                    }
                )
            })
        })
    })

    return Widget.Box({
        class_name: "workspaces",
        spacing: 5,
        children: workspaces,
    });
}

// layout of the bar
function Left(monitor: number) {
    return Widget.Box({
        spacing: 8,
        children: [
            // NixLogo(),
            Workspaces(monitor),
            // ClientTitle(),
        ],
    })
}

/*
function Center() {
    return Widget.Box({
        spacing: 8,
        children: [
            Media(),
            Notification(),
        ],
    })
}
*/

function Bar(monitor = 0) {
    return Widget.Window({
        name: `bar-${monitor}`, // name has to be unique
        monitor,
        anchor: ["top", "left", "right"],
        exclusivity: "exclusive",
        child: Widget.CenterBox({
        class_name: "bar",

            start_widget: Left(monitor),
            // center_widget: Center(),
            end_widget: RightSide(),
        }),
    })
}
