import { Gtk } from "astal/gtk3";
import Volume from "./Volume";
import Time from "./Time";
import StatusIcons from "./StatusIcons/StatusIcons";
import BatteryLvl from "./BatteryLvl";
import BrightnessLvl from "./BrightnessLvl";

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
