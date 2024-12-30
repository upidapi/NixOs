import { bind } from "astal";

import Brightness from "../../services/brightness";
import DataContainer from "../DataContainer";
import { AsciiStatusIcon } from "../StatusIcon";

export default function BrightnessLvl() {
  const brightness = new Brightness();

  return (
    <DataContainer visible={bind(brightness, "hasBacklight")}>
      <AsciiStatusIcon
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
