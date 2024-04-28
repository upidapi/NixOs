{...}: let
  mod = a: b: a - builtins.floor (a / b) * b;
in {
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
        "$mod, S, exec, $TERMINAL"
        "$mod, D, exec, rofi -show drun"
        "$mod, F, exec, firefox"

        "$mod, C, killactive"
        "$mod, M, exit"

        # volume
        ",code:122, exec, pamixer -t" # toggle mute
        ",code:123, exec, pamixer -d 5" # dec vol
        ",code:121, exec, pamixer -i 5" # inc vol

        # move focus with arrow keys
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # move window with arrow keys
        "$mod CTRL, left, movewindow, l"
        "$mod CTRL, right, movewindow, r"
        "$mod CTRL, up, movewindow, u"
        "$mod CTRL, down, movewindow, d"

        # move focus with vim keys
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # move window with vim keys
        "$mod CTRL, H, movewindow, l"
        "$mod CTRL, L, movewindow, r"
        "$mod CTRL, K, movewindow, u"
        "$mod CTRL, J, movewindow, d"
        # "$mod, F, exec, firefox"
        # ", Print, exec, grimblast copy area"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
        builtins.concatLists (
          builtins.genList (
            x: let
              # number bind
              nb = toString (mod (x + 1) 10);

              # workspace name
              wn = toString (x + 1);
            in [
              # go to workspace n
              "$mod, ${nb}, workspace, ${wn}"

              # move active to workspace n
              "$mod CTRL, ${nb}, movetoworkspace, ${wn}"

              # move active to workspace n, preserve workspace focus
              "$mod CTRL SHIFT, ${nb}, movetoworkspacesilent, ${wn}"

              # switch the place of two worksapces
              "$mod ALT, ${nb}, focusworkspaceoncurrentmonitor, ${wn}"
            ]
          )
          10
        )
      );
  };
}
