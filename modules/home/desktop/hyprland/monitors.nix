{
  osConfig,
  lib,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
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
        m: "${m.name},${toString m.workspace}"
      )
      (
        lib.filter
        (m: m.enabled)
        osConfig.modules.nixos.hardware.monitors
      );
  };
}
