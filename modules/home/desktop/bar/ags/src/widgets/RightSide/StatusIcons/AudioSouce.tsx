import { bind } from "astal";
import Wp from "gi://AstalWp";
import { AsciiStatusIcon } from "../../StatusIcon";

export default function AudioSource() {
  const audio = Wp.get_default()!;
  return (
    <AsciiStatusIcon
      icon={bind(audio.audio.defaultSpeaker, "icon").as((icon) => {
        if (icon === "audio-headset-bluetooth") {
          return "󰋋";
        }

        return "";
      })}
    />
  );
}
