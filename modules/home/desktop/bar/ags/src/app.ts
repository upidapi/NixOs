import { App } from "astal/gtk3";
import style from "./style.scss";
import Bar from "./widgets/Bar";
import Hyprland from "gi://AstalHyprland";

const hyprland = Hyprland.get_default();
App.start({
  css: style,
  main() {
    hyprland.monitors.map((i, _) => Bar(i.id));
    // App.get_monitors().map(Bar);
  },
});
