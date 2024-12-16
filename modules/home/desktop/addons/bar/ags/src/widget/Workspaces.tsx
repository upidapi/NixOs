import { Variable, bind } from "astal";
import Hyprland from "gi://AstalHyprland";

import { pp } from "../Helpers";

export default function Workspaces({ monitor_id }: { monitor_id: number }) {
    const hyprland = Hyprland.get_default();

    const workspaces = Array.from({ length: 10 }, (_, index) => {
        const id = index + 1;

        const class_name = Variable.derive(
            [
                bind(hyprland, "monitors"),
                bind(hyprland, "workspaces"),
                // is here to force updates when changing workspace
                // otherwise, for some reason the "current workspace"
                // sometimes lacks behind
                bind(hyprland, "focusedWorkspace"),
            ],
            (monitors, workspaces) => {
                // pp(monitors);

                const workspace_type = (() => {
                    // if (id === focus.id) {
                    const monitor = monitors.find((monitor) => monitor.id === monitor_id)!;

                    // pp(monitor)
                    if (id === monitor.activeWorkspace.id) {
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

                // print(workspace_type);

                return `workspace workspace_${workspace_type}`;
            },
        );

        return (
            <button
                onClicked={() =>
                    hyprland.message_async(
                        `dispatch focusworkspaceoncurrentmonitor ${id}`,
                        null,
                    )
                }
            >
                <label label={(id % 10).toString()} className={bind(class_name)} />
            </button>
        );
    });

    return (
        <box className={"workspaces"} spacing={5}>
            {workspaces}
        </box>
    );
}
