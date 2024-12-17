import {exec, monitorFile } from "astal"
import GObject, { register, property , signal } from "astal/gobject"

@register({ GTypeName: "Brightness" })
export default class Brightness extends GObject.Object {
    declare private _value: number
    declare private _interface: string
    declare private _max: number
    declare private _iconName: string

    @property(Number)
    get value() {
        return this._value;
    }
    set value(value: number) {
        exec(`brightnessctl set ${Math.round(value * this._max)}`);
        this._value = value;
        this.emit("value_changed", value);
    }

    @property(String)
    get iconName() {
        if (this._value < 0.25) {
            return "display-brightness-low-symbolic"
        } else if (this._value < 0.75) {
            return "display-brightness-medium-symbolic"
        } else {
            return "display-brightness-high-symbolic"
        }
    }


    constructor() {
        super()
        this._interface = exec("sh -c 'ls -w1 /sys/class/backlight | head -1'");
        this._max = Number(exec('brightnessctl max'));
        this._value = 0
        const brightness = `/sys/class/backlight/${this._interface}/brightness`;
        monitorFile(brightness, () => this.onChange());

        //Init
        this.onChange();
    }

    onChange() {
        this._value = Number(exec("brightnessctl get")) / this._max;
        // Update
        this.notify("icon-name");
        this.notify("value");
        //this.emit("value-changed", this._value);
    }

    @signal(Number)
    declare valueChanged: (value: Number) => void
}
