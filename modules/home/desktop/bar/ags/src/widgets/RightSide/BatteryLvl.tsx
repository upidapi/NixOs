import { Variable, bind, execAsync } from "astal";
import Battery from "gi://AstalBattery";
import DataContainer from "../DataContainer";

let last_percent = -1;
const battery = Battery.get_default();
export default function BatteryLvl() {
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
