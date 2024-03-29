{osConfig, ...}: {
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    # mouse binds
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    # kbd binds
    bind =
      [
        # "$mod, Q, exec, kitty"
        "$mod, E, exec, alacritty"
        "$mod, R, exec, firefox"
        "$mod, C, killactive"
        "$mod, M, exit"
        # "$mod, F, exec, firefox"
        # ", Print, exec, grimblast copy area"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
        builtins.concatLists (builtins.genList (
            x: let
              ws = let
                c = (x + 1) / 10;
              in
                builtins.toString (x + 1 - (c * 10));
            in [
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
            ]
          )
          10)
      );

    # display conf
    /* monitor =
      map
      (
        m: let
          resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
          position = "${toString m.x}x${toString m.y}";
        in "${m.name},${
          if m.enabled
          then "${resolution},${position},1"
          else "disable"
        }"
      )
      (osConfig.modules.nixos.hardware.monitors); */

    # layout
    input = {
      kb_layout = "se"; # swedish layout
    };
  };
}
