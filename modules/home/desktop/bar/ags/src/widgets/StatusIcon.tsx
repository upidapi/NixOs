import { Binding } from "astal";

export function StatusIcon({ icon }: { icon: Binding<string> }) {
  return <icon icon={icon} visible={icon.as((i) => i != "")} />;
}

export function AsciiStatusIcon({ icon }: { icon: Binding<string> }) {
  return <label label={icon} visible={icon.as((i) => i != "")} />;
}
