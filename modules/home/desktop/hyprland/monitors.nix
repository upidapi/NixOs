{
  osConfig,
  lib,
  ...
}: {
  wayland.windowManager.hyprland.settings = let
    enabledMonitors = (
      lib.filter
      (m: m.enabled)
      osConfig.modules.nixos.hardware.monitors
    );
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
          then "${resolution},${position},1"
          else "disable"
        }"
      )
      (osConfig.modules.nixos.hardware.monitors);

    # assign each monitor the correct workspace
    workspace =
      map
      (
        m: "${toString m.workspace}, monitor:${m.name}, default:true"
      )
      enabledMonitors;

    # move cursor to primary workspace
    exec-once = let
      # there can't be more than one (due to assertions)
      primaryMonitorCandidates =
        builtins.filter
        (m: m.primary)
        enabledMonitors;
    in
      # handle case where there are no primary monitor
      if builtins.length primaryMonitorCandidates == 0
      then []
      else let
        primaryMonitor = builtins.elemAt primaryMonitorCandidates 0;
      in ["hyprctl dispatch workspace ${primaryMonitor.name}"];
  };
}
