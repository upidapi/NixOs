import { Variable, bind } from "astal";
// import Astal from "gi://Astal?version=3.0";

import Wp from "gi://AstalWp";
import DataContainer from "../DataContainer";

export default function Volume() {
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
