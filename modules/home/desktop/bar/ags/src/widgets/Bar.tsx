import { App, Astal } from "astal/gtk3";
import { Variable } from "astal";

import Workspaces from "./Workspaces";
import Right from "./Right";

// const date = Variable("").poll(
//     1000,
//     `bash -c "LC_ALL=en_GB.utf8 date +'%Y-%m-%d %a %H:%M:%S'"`,
// );
// function Time() {
//     return <label className={"time"} label={date()} />;
// }

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
                <box />
                <Right />
            </centerbox>
        </window>
    );
}
