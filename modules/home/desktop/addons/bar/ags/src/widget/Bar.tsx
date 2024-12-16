import { App, Astal } from "astal/gtk3";
import Workspaces from "./Workspaces";
import Left from "./Left";

export default function Bar(monitor: number) {
    return (
        <window
            // gdkmonitor={gdkmonitor}
            monitor={monitor}
            exclusivity={Astal.Exclusivity.EXCLUSIVE}
            anchor={
                Astal.WindowAnchor.TOP |
                Astal.WindowAnchor.LEFT |
                Astal.WindowAnchor.RIGHT
            }
            application={App}
        >
            <centerbox className="bar">
                <Workspaces monitor_id={monitor} />
                <label label={"hello"}/>
                <Left/>
            </centerbox>
        </window>
    );
}
