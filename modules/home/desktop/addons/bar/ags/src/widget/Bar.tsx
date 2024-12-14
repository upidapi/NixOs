import { App, Astal, Gtk, Gdk } from "astal/gtk3";
import { Variable, bind } from "astal";
import Hyprland from "gi://AstalHyprland";
//
// function Workspaces(monitor_id: number) {
//     const workspaces = Array.from({length: 10}, (_, index) => {
//         const id = index + 1
//         return Widget.Button({
//             on_clicked: () => hyprland.messageAsync(
//                 `dispatch focusworkspaceoncurrentmonitor ${id}`
//             ),
//
//             child: Widget.Label({
//                 label: id.toString(),
//                 class_name: Utils.merge(
//                     [
//                         hyprland.bind("workspaces"),
//                         hyprland.bind("monitors"),
//                     ],
//                     (workspaces, monitors) => {
//                         const workspace_type = (() => {
//                             if (id === monitors[monitor_id].activeWorkspace.id) {
//                                 return "current"
//                             }
//
//                             if (
//                                 monitors.map((monitor) =>
//                                     monitor.activeWorkspace.id
//                                 ).includes(id)
//                             ) {
//                                 return "focused"
//                             }
//
//                             if (
//                                 workspaces.map((workspace) =>
//                                     workspace.id
//                                 ).includes(id)
//                             ) {
//                                 return "active"
//                             }
//
//                             return "inactive"
//                         })()
//
//                         return `workspace workspace_${workspace_type}`
//                     }
//                 )
//             })
//         })
//     })
//
//     return Widget.Box({
//         class_name: "workspaces",
//         spacing: 5,
//         children: workspaces,
//     });
// }

function Workspaces({ monitor_id }: { monitor_id: number }) {
    const workspaces = Array.from({ length: 10 }, (_, index) => {
        const id = index + 1;

        const class_name = Variable.derive(
            [bind(hyprland, "workspaces"), bind(hyprland, "monitors")],
            (workspaces, monitors) => {
                const workspace_type = (() => {
                    if (id === monitors[monitor_id].activeWorkspace.id) {
                        return "current";
                    }

                    if (
                        monitors.map((monitor) => monitor.activeWorkspace.id).includes(id)
                    ) {
                        return "focused";
                    }

                    if (workspaces.map((workspace) => workspace.id).includes(id)) {
                        return "active";
                    }

                    return "inactive";
                })();

                return `workspace workspace_${workspace_type}`;
            },
        );

        return (
            <button
                onClicked={() =>
                    hyprland.messageAsync(`dispatch focusworkspaceoncurrentmonitor ${id}`)
                }
            >
                <label
                    label={id.toString()}
                    className={bind(class_name)}
                />
            </button>
        );
    });
    return (
        <box>
            <label label="test"></label>
            {workspaces}
        </box>
    );
}

const time = Variable("").poll(1000, "date");

export default function Bar(gdkmonitor: Gdk.Monitor) {
    return (
        <window
            className="bar"
            gdkmonitor={gdkmonitor}
            exclusivity={Astal.Exclusivity.EXCLUSIVE}
            anchor={
                Astal.WindowAnchor.TOP |
                Astal.WindowAnchor.LEFT |
                Astal.WindowAnchor.RIGHT
            }
            application={App}
        >
            <centerbox>
                <button onClicked="echo hello" halign={Gtk.Align.CENTER}>
                    <box>
                        <label label={"--|"} />
                        <Workspaces monitor_id={1} />
                        <label label={"|--"} />
                    </box>
                </button>
                <box />
                <button onClick={() => print("hello")} halign={Gtk.Align.CENTER}>
                    <label label={time()} />
                </button>
            </centerbox>
        </window>
    );
}
