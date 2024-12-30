import { Variable, exec } from "astal";
import { StatusAsciiIcon } from "./StatusIcon";

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

export default function AirplainStatusIcon() {
  return (
    <StatusAsciiIcon
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
