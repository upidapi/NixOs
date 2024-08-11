{
  osConfig,
  lib,
  ...
}: {
  wayland.windowManager.hyprland.settings = let
    monitorCfg = osConfig.modules.nixos.hardware.monitors;
    monitorList = builtins.attrValues monitorCfg.monitors;
    enabledMonitors =
      lib.filter
      (m: m.enabled)
      monitorList;
  in {
    # display conf
    monitor =
      map
      (
        m: let
          # sm, i.e string monitors
          resolution = "${
            toString m.width
          }x${
            toString m.height
          }@${
            toString m.refreshRate
          }";

          position = "${
            toString m.x
          }x${
            toString m.y
          }";
        in "${m.name},${
          if m.enabled
          then "${resolution},${position},${toString m.scale}"
          else "disable"
        }"
      )
      monitorList;

    # assign each monitor the correct workspace
    workspace =
      map
      (
        m: "${toString m.workspace}, monitor:${m.name}, default:true"
      )
      enabledMonitors;

    # move cursor to primary workspace
    exec-once = [
      "hyprctl dispatch focusmonitor ${monitorCfg.primaryMonitor}"
    ];
  };
}
