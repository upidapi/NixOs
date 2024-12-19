import { Gtk } from "astal/gtk3";
import { Binding, Variable, bind, exec, execAsync } from "astal";
// import Astal from "gi://Astal?version=3.0";

import Wp from "gi://AstalWp";
import Battery from "gi://AstalBattery";
import Network from "gi://AstalNetwork";
import Brightness from "../services/brightness";
// import Bluetooth from "gi://AstalBluetooth";

import { pp } from "../Helpers";

import DataContainer from "./DataContainer";

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
function BatteryLvl() {
    // pp(battery);

    const icon = Variable.derive(
        [bind(battery, "charging"), bind(battery, "percentage")],
        (charging: boolean, percent: number) => {
            percent *= 100;
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
                p <= 0.1 ? "battery-low" : "",
            )}
            visible={bind(battery, "isPresent")}
        >
            <label label={icon()} />
            <label
                label={bind(battery, "percentage").as((p) => {
                    return `${Math.round(p * 100)}%`;
                })}
            />
        </DataContainer>
    );
}

function Icon({ icon }: { icon: Binding<string> }) {
    return <icon icon={icon} visible={icon.as((i) => i != "")} />;
}

function AsciiIcon({ icon }: { icon: Binding<string> }) {
    return <label label={icon} visible={icon.as((i) => i != "")} />;
}

type RfkillData = {
    rfkilldevices: {
        id: number;
        type: string;
        device: string;
        soft: "unblocked" | "blocked";
        hard: "unblocked" | "blocked";
    }[];
};

const initial_frkill_data: RfkillData = JSON.parse(exec("rfkill -J"));
const rfkill_data = Variable<RfkillData>(initial_frkill_data).watch(
    "rfkill event",
    // {
    //    "rfkilldevices": [
    //       {
    //          "id": 0,
    //          "type": "bluetooth",
    //          "device": "hci0",
    //          "soft": "unblocked",
    //          "hard": "unblocked"
    //       },{
    //          "id": 1,
    //          "type": "wlan",
    //          "device": "phy0",
    //          "soft": "unblocked",
    //          "hard": "unblocked"
    //       }
    //    ]
    // }
    //
    // 2024-12-17 08:59:18,270941+01:00: idx 0 type 2 op 0 soft 0 hard 0
    // 2024-12-17 08:59:18,270982+01:00: idx 1 type 1 op 0 soft 0 hard 0
    //
    // op
    //     0 := init
    //     2 := update
    //
    // soft/hard 1 turns it on
    // soft/hard 0 turns it off
    //
    // idx is the id of the device
    (d: string, prev: RfkillData) => {
        prev.rfkilldevices.sort((a, b) => a.id - b.id);

        const next = JSON.parse(JSON.stringify(prev));
        const regex = /idx (\d+) type (\d+) op (\d+) soft (\d+) hard (\d+)/;

        // Execute regex on the string
        // print(d)
        const match = d.match(regex);

        // Variables to hold the extracted values
        if (match) {
            const [idx, _type, _op, soft, hard] = match.slice(1).map(Number);

            // Output the variables
            // console.log("idx:", idx);
            // console.log("type:", type);
            // console.log("op:", op);
            // console.log("soft:", soft);
            // console.log("hard:", hard);

            next.rfkilldevices[idx].soft = soft ? "blocked" : "unblocked";
            next.rfkilldevices[idx].hard = hard ? "blocked" : "unblocked";
        } else {
            // console.log("No match found.");
            throw "fuck";
        }

        return next;
    },
);

function AirplainIcon() {
    return (
        <AsciiIcon
            icon={rfkill_data((d: RfkillData): string => {
                // print(d);

                for (const dev of d.rfkilldevices) {
                    if (dev.soft == "blocked") {
                        return "󰀝";
                    }
                    // return "";
                }

                return "";
            })}
        />
    );
}

function NetworkIcon() {
    const network = Network.get_default();

    pp(network);
    return (
        <Icon
            icon={Variable.derive(
                [
                    bind(network, "primary"),

                    bind(network, "wifi"),
                    bind(network, "wired"),
                ],
                (primary, wifi, wired) => {
                    return {
                        // should not occur
                        [Network.Primary.UNKNOWN]: "network-wireless-offline-symbolic",
                        [Network.Primary.WIFI]: wifi == null ? "error" : wifi.iconName,
                        [Network.Primary.WIRED]: wired.iconName,
                    }[primary];
                },
            )()}
        />
    );
}

function AudioIcons() {
    const audio = Wp.get_default()!;
    return (
        <AsciiIcon
            icon={bind(audio.audio.defaultSpeaker, "icon").as((icon) => {
                if (icon === "audio-headset-bluetooth") {
                    return "󰋋";
                }

                return "";
            })}
        />
    );
}

function StatusIcons() {
    return (
        <DataContainer>
            <AudioIcons />
            <AirplainIcon />
            <NetworkIcon />
        </DataContainer>
    );
}

function BrightnessLvl() {
    const brightness = new Brightness();

    return (
        <DataContainer visible={bind(brightness, "hasBacklight")}>
            <AsciiIcon
                icon={bind(brightness, "value").as(
                    (p: number) => [..."󰛩󱩎󱩏󱩐󱩑󱩒󱩓󱩔󱩕󱩖󰛨"][Math.round(p * 10)],
                )}
            />
            <label
                label={bind(brightness, "value").as(
                    (p: number) => `${Math.round(p * 100)}%`,
                )}
            />
        </DataContainer>
    );
}

export default function Right() {
    return (
        <box halign={Gtk.Align.END} spacing={5}>
            <StatusIcons />
            <BatteryLvl />
            <BrightnessLvl />
            <Volume />
            <Time />
        </box>
    );
}
