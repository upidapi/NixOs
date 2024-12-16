import { Gtk } from "astal/gtk3";
import { Variable, bind, execAsync } from "astal";
import { Widget } from "astal/gtk3";
import Wp from "gi://AstalWp";
import Battery from "gi://AstalBattery";
import { pp } from "../Helpers";
import Astal from "gi://Astal?version=3.0";
import Bar from "./Bar";

function DataContainer({
    child,
    children,
    className = "",
    visible = true,
}: Widget.BoxProps) {
    return (
        <box
            spacing={5}
            className={"container " + className}
            homogeneous={false}
            visible={visible}
        >
            {child}
            {children}
        </box>
    );
}

const date = Variable("").poll(
    1000,
    `bash -c "LC_ALL=en_GB.utf8 date +'%Y-%m-%d %a %H:%M:%S'"`,
);
function Time() {
    return (
        <DataContainer>
            <label label={date()} />
        </DataContainer>
    );
}

function Volume() {
    const audio = Wp.get_default()?.audio.defaultSpeaker!;

    function getIcon(volume: number, mute: boolean) {
        if (mute) {
            return "audio-volume-muted-symbolic";
        }

        const icon = (
            [
                [101, "overamplified"],
                [67, "high"],
                [33, "medium"],
                [0, "low"],
            ] as const
        ).find(([threshold, _]) => threshold <= volume * 100)![1];

        return `audio-volume-${icon}-symbolic`;
    }

    return (
        <DataContainer>
            <icon
                icon={Variable.derive(
                    [bind(audio, "volume"), bind(audio, "mute")],
                    getIcon,
                )()}
            />
            <label
                label={bind(audio, "volume").as((vol) => `${Math.round(vol * 100)}%`)}
            />
        </DataContainer>
    );
}

let last_percent = -1;
const battery = Battery.get_default();
function BatteryLevel() {
    // pp(battery);

    const icon = Variable.derive(
        [bind(battery, "charging"), bind(battery, "percentage")],
        (charging: boolean, percent: number) => {
            // print(last_percent, percent)

            // notify when battery decreases
            if (last_percent > percent) {
                // Utils.execAsync([
                //     "notify-send",
                //     "-u",
                //     "normal",
                //     "Low Battery",
                //     `${percent}% battery remaining`,
                // ]);

                if (percent == 20) {
                    execAsync([
                        "notify-send",
                        "-u",
                        "normal",
                        "Low Battery",
                        `20% battery remaining`,
                    ]);
                } else if (percent == 10) {
                    execAsync([
                        "notify-send",
                        "-u",
                        "normal",
                        "Low Battery",
                        `10% battery remaining`,
                    ]);
                } else if (percent == 5) {
                    execAsync([
                        "notify-send",
                        "-u",
                        "critical",
                        "Low Battery",
                        `5% battery remaining`,
                    ]);
                }
            }

            last_percent = percent;

            if (charging) {
                return "󰂄";
            }

            if (percent < 0) {
                return "";
            }

            return [..."󰂎󰁺󰁻󰁼󰁽󰁾󰁿󰂀󰂁󰂂󰁹"][Math.round(percent / 10)];
        },
    );

    return (
        <DataContainer
            className={bind(battery, "percentage").as((p) =>
                p <= 10 ? "battery-low" : "",
            )}
            visible={bind(battery, "isPresent")}
        >
            <label label={icon()} />
            <label
                label={bind(battery, "percentage")
                    .as(p => {
                        pp(p)
                        return `${Math.round(p)}%`})}
            />
        </DataContainer>
    );
}

function Icon({icon}: {icon: string}) {
    return <label label={icon} visible={icon != ""}/>
}

function AudioIcons() {
    const audio = Wp.get_default()
    pp(audio)
    return <>
        <Icon icon="a"/>
    </>
}

function StatusIcons() {
    return <DataContainer>
        <AudioIcons/>
    </DataContainer>
}
export default function Right() {
    return (
        <box halign={Gtk.Align.END} spacing={5}>
            <StatusIcons />
            <BatteryLevel />
            <Volume />
            <Time />
        </box>
    );
}
