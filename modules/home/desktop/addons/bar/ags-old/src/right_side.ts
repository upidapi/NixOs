import Gtk from "gi://Gtk?version=3.0";

function DataContainer({ ...src }) {
    return Widget.Box({
        ...src,
        spacing: 5,
        class_name: "container",
        homogeneous: false,
        vertical: false,
    });
}

const date = Variable("", {
    poll: [1000, `bash -c "LC_ALL=en_GB.utf8 date +'%Y-%m-%d %a %H:%M:%S'"`],
});

function Time() {
    return [
        DataContainer({
            children: [
                Widget.Label({
                    label: date.bind(),
                }),
            ],
        }),
    ];
}

const audio = await Service.import("audio");

function Volume() {
    const icons = {
        101: "overamplified",
        67: "high",
        33: "medium",
        0: "low",
    };

    function getIcon() {
        if (audio.speaker.is_muted) {
            return "audio-volume-muted-symbolic";
        }

        const icon_val = [101, 67, 33, 0].find(
            (threshold) => threshold <= audio.speaker.volume * 100,
        ) as number;

        return `audio-volume-${icons[icon_val]}-symbolic`;
    }

    return [
        DataContainer({
            children: [
                Widget.Icon({
                    icon: Utils.watch(getIcon(), audio.speaker, getIcon),
                }),
                Widget.Label({
                    label: audio.speaker
                        .bind("volume")
                        .as((vol) => `${Math.round(vol * 100)}%`),
                }),
            ],
        }),
    ];
}

const battery = await Service.import("battery");

let last_percent = -1;

function Battery() {
    const value = battery.bind("percent").as((p: number) => `${Math.round(p)}%`);

    const icon = Utils.merge(
        [battery.bind("charging"), battery.bind("percent")],
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
                    Utils.execAsync([
                        "notify-send",
                        "-u",
                        "normal",
                        "Low Battery",
                        `20% battery remaining`,
                    ]);
                } else if (percent == 10) {
                    Utils.execAsync([
                        "notify-send",
                        "-u",
                        "normal",
                        "Low Battery",
                        `10% battery remaining`,
                    ]);
                } else if (percent == 5) {
                    Utils.execAsync([
                        "notify-send",
                        "-u",
                        "critical",
                        "Low Battery",
                        `5% battery remaining`,
                    ]);
                }
            }
            
            last_percent = percent

            if (charging) {
                return "󰂄";
            }

            if (percent < 0) {
                return "";
            }

            return [..."󰂎󰁺󰁻󰁼󰁽󰁾󰁿󰂀󰂁󰂂󰁹"][Math.round(percent / 10)];
        },
    );

    const low_battery_class = battery
        .bind("percent")
        .as((percent: number) => (percent <= 10 ? ["battery-low"] : []));

    return [
        DataContainer({
            visible: battery.bind("available"),
            children: [
                // Widget.Label({
                //     label: battery.bind().as(() => {
                //         print(JSON.stringify(Object.entries(battery)));
                //         print(battery.percent());
                //         return "-";
                //     }),
                // }),
                Widget.Label({
                    label: icon,
                    class_names: low_battery_class,
                }),
                Widget.Label({
                    label: value,
                    class_names: low_battery_class,
                }),
            ],
        }),
    ];
}

class BrightnessService extends Service {
    // every subclass of GObject.Object has to register itself
    static {
        // takes three arguments
        // the class itself
        // an object defining the signals
        // an object defining its properties
        Service.register(
            this,
            {
                // 'name-of-signal': [type as a string from GObject.TYPE_<type>],
                "screen-changed": ["float"],
            },
            {
                // 'kebab-cased-name': [type as a string from GObject.TYPE_<type>, 'r' | 'w' | 'rw']
                // 'r' means readable
                // 'w' means writable
                // guess what 'rw' means
                "screen-value": ["float", "rw"],
                "has-backlight": ["boolean", "r"],
            },
        );
    }

    // this Service assumes only one device with backlight
    #interface = Utils.exec("sh -c 'ls -w1 /sys/class/backlight | head -1'");

    // # prefix means private in JS
    #screenValue = 0;
    #hasBacklight = this.#interface == "" ? false : true;
    #max = Number(Utils.exec("brightnessctl max"));

    get has_backlight() {
        return this.#hasBacklight;
    }

    // the getter has to be in snake_case
    get screen_value() {
        return this.#screenValue;
    }

    // the setter has to be in snake_case too
    set screen_value(percent) {
        if (percent < 0) percent = 0;

        if (percent > 1) percent = 1;

        Utils.execAsync(`brightnessctl set ${percent * 100}% -q`);
        // the file monitor will handle the rest
    }

    constructor() {
        super();

        if (this.#hasBacklight) {
            // setup monitor
            const brightness = `/sys/class/backlight/${this.#interface}/brightness`;
            Utils.monitorFile(brightness, () => this.#onChange());
        }

        // initialize
        this.#onChange();
    }

    #onChange() {
        this.#screenValue = Number(Utils.exec("brightnessctl get")) / this.#max;

        // signals have to be explicitly emitted
        this.emit("changed"); // emits "changed"
        this.notify("screen-value"); // emits "notify::screen-value"

        // or use Service.changed(propName: string) which does the above two
        // this.changed('screen-value');

        // emit screen-changed with the percent as a parameter
        this.emit("screen-changed", this.#screenValue);
    }

    // overwriting the connect method, let's you
    // change the default event that widgets connect to
    connect(event = "screen-changed", callback) {
        return super.connect(event, callback);
    }
}

const brightness = new BrightnessService();

function Brigtness() {
    return [
        DataContainer({
            visible: brightness.bind("has_backlight"),
            children: [
                Widget.Label({
                    label: brightness.bind("screen_value").as(
                        (p: number) =>
                            // "󰛩󱩎󱩏󱩐󱩑󱩒󱩓󱩔󱩕󱩖󰛨"[Math.round(p * 10)]
                            [..."󰛩󱩎󱩏󱩐󱩑󱩒󱩓󱩔󱩕󱩖󰛨"][Math.round(p * 10)],
                        // `${Math.round(p * 10)}`
                    ),
                }),
                Widget.Label({
                    label: brightness
                        .bind("screen_value")
                        .as((p: number) => `${Math.round(p * 100)}%`),
                }),
            ],
        }),
    ];
}

function Icon(icon) {
    return Widget.Icon({
        visible: icon.as((i: string) => i != ""),
        icon: icon,
    });
}

const network = await Service.import("network");

function NetworkIcon() {
    return [
        Icon(
            Utils.merge(
                [
                    network.bind("primary"),
                    network.wifi.bind("icon_name"),
                    network.wired.bind("icon_name"),
                ],
                (type: string | null, wifi_icon: string, wired_icon: string) => {
                    if (type == null) {
                        type = "network-wireless-offline-symbolic";
                    }

                    if (type == "wifi") {
                        return wifi_icon;
                    }

                    if (type == "wired") {
                        return wired_icon;
                    }
                },
            ),
        ),
    ];
}

const raw_rfkill_data = Variable("false", {
    poll: [100, "rfkill -J"],
});

function AirplaneIcon() {
    return [
        Icon(
            raw_rfkill_data.bind().as((data) => {
                const parsed = JSON.parse(data);
                for (const dev of parsed.rfkilldevices) {
                    if (dev.soft == "blocked") {
                        return "airplane-mode-symbolic";
                    }
                    return "";
                }
            }),
        ),
    ];
}

// const bluetooth = await Service.import("bluetooth");
//
// const raw_bth_data = Variable("", {
//     poll: [100, "bash -c 'bluetoothctl info || :'"],
// });
//
// function getParsedBthCtl(data: string): { [key: string]: any }[] {
//     try {
//         const rawDataLines = data.split("\n");
//
//         const devices: string[][] = [];
//         let start = -1;
//         for (let i = 0; i < rawDataLines.length; i++) {
//             const line = rawDataLines[i];
//             if (line.startsWith("Device ")) {
//                 if (start !== -1) {
//                     devices.push(rawDataLines.slice(start, i));
//                 }
//                 start = i;
//             }
//         }
//         devices.push(rawDataLines.slice(start));
//
//         const parsed: { [key: string]: any }[] = [];
//         for (const device of devices) {
//             const parsedDevice: { [key: string]: any } = { name: device[0] };
//
//             for (let i = 1; i < device.length; i++) {
//                 const [name, data] = device[i].split(": ", 2);
//                 const key = name.slice(1);
//                 if (!(key in parsedDevice)) {
//                     parsedDevice[key] = data;
//                 } else if (Array.isArray(parsedDevice[key])) {
//                     parsedDevice[key].push(data);
//                 } else {
//                     parsedDevice[key] = [parsedDevice[key], data];
//                 }
//             }
//
//             parsed.push(parsedDevice);
//         }
//
//         return parsed;
//     } catch (error) {
//         return [];
//     }
// }
//
// function BthHeadphoneIcon() {
//     const icon = raw_bth_data.bind().as((data) => {
//         if (data == "") {
//             return "";
//         }
//
//         const parsed = getParsedBthCtl(data);
//         for (const connection of parsed) {
//             if (connection["Icon"] === "audio-headset") {
//                 return "󰋋";
//             }
//         }
//
//         return "";
//     });
//
//     return Icon(icon);
// }

function AudioIcons() {
    const icon = audio.speaker.bind("stream").as((data) => {
        if (data === null) {
            return "";
        }

        if (data["icon-name"] === "audio-headset-bluetooth") {
            return "󰋋";
        }

        return "";
    });

    return [
        Widget.Label({
            visible: icon.as((x: string) => x != ""),
            label: icon,
        }),
        // Icon(
        //     audio.microphone.bind("stream").as((data) => {
        //         if (data === null) {
        //             return "";
        //         }
        //
        //         return data["icon-name"];
        //     }),
        // ),
    ];
}

// function MicIcon() {
//     // print(JSON.stringify(audio))
//     // print()
//     return []
// }

function StatusIcons() {
    return [
        DataContainer({
            children: [
                NetworkIcon(),
                AirplaneIcon(),
                // MicIcon(),
                AudioIcons(),
            ].flat(1),
        }),
    ];
}

export function RightSide() {
    return Widget.Box({
        hpack: "end",
        spacing: 5,
        children: [StatusIcons(), Battery(), Brigtness(), Volume(), Time()].flat(1),
    });
}
