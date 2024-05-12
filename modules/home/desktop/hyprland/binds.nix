{...}: let
  mod = a: b: a - builtins.floor (a / b) * b;
in {
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    # flags
    /*
    l -> locked, will also work when an input inhibitor (e.g. a
    lockscreen) is active.

    r -> release, will trigger on release of a key.

    e -> repeat, will repeat when held.

    n -> non-consuming, key/mouse events will be passed to the
    active window in addition to triggering the dispatcher.

    m -> mouse, see below

    t -> transparent, cannot be shadowed by other binds.

    i -> ignore mods, will ignore modifiers.
    */

    # mouse binds
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    # TODO: brigtness / airplane mode, indecators / notifications§
    bindle = [
      # change volume
      ",XF86AudioMute, exec, pamixer -t"
      ",XF86AudioRaiseVolume, exec, pamixer -i 5"
      ",XF86AudioLowerVolume, exec, pamixer -d 5"
      # brigtness
      # ",XF86MonBrightnessUp, exec, brightnessctl s 2%+"
      # ",XF86MonBrightnessDown, exec, brightnessctl s 2%-"
    ];

    # NOTE: you can use wev to see the keysym for a button
    #  (nix-shell -p wev)

    bindli = [
      ",XF86AudioPrev, exec, playerctl previous"
      ",XF86AudioNext, exec, playerctl next"
      # NOTE: my keyboard seams to only send XF86AudioPlay
      #  if this is a problem rebind it to playerctl play-pause

      ",XF86AudioPlay, exec, playerctl play"
      ",XF86AudioPause, exec, playerctl pause"
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

        # screen shot
        (
          ",Print , exec, "
          + "grim -g \"$(slurp -w 0)\" - | wl-copy"
        )

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
        # TODO: make SUPER + {num} switch the current worksapce with num workspace
        # TODO: make SUPER + ALT + {num} go the the {num} display/monitor
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
