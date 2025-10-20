let
  mod = a: b: a - builtins.floor (a / b) * b;

  genNumKeysBins = f:
    builtins.genList (
      x: let
        # number bind
        nb = toString (mod (x + 1) 10);

        # workspace name
        wn = toString (x + 1);
      in
        (f nb) wn
    )
    10;

  mkArrowBind = mods: cmd: [
    "$mod ${mods}, left, ${cmd}, l"
    "$mod ${mods}, right, ${cmd}, r"
    "$mod ${mods}, up, ${cmd}, u"
    "$mod ${mods}, down, ${cmd}, d"

    "$mod ${mods}, H, ${cmd}, l"
    "$mod ${mods}, L, ${cmd}, r"
    "$mod ${mods}, K, ${cmd}, u"
    "$mod ${mods}, J, ${cmd}, d"
  ];
in {
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    # flags
    /*
        l -> locked, will also work when an input inhibitor (e.g. a
        lockscreen) is active.

        r -> release, will trigger on release of a key.

        e -> repeat, will repeat when held.
    n -> non-consuming, key/mouse events will be passed to the active window in addition to triggering the dispatcher.

        m -> mouse, see below

        t -> transparent, cannot be shadowed by other binds.

        i -> ignore mods, will ignore modifiers.
    */

    # mouse binds
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    bindle = [
      # change volume
      ",XF86AudioMute, exec, pamixer -t"
      ",XF86AudioRaiseVolume, exec, pamixer -i 5 --allow-boost --set-limit 200"
      ",XF86AudioLowerVolume, exec, pamixer -d 5 --allow-boost --set-limit 200"

      "SHIFT, XF86AudioRaiseVolume, exec, pamixer -i 1 --allow-boost --set-limit 200"
      "SHIFT, XF86AudioLowerVolume, exec, pamixer -d 1 --allow-boost --set-limit 200"

      # brigtness
      ",XF86MonBrightnessUp, exec, brightnessctl --exponent=1.9 set 5%+"
      ",XF86MonBrightnessDown, exec, brightnessctl --exponent=1.9 set 5%-"
    ];

    # NOTE: you can use wev to see the keysym for a button
    #  (nix-shell -p wev)

    bindli =
      # media controls
      let
        # Only try the currently focused one
        # Otherwise it's gonna try everyone (in order) until it
        # finds an available one, which can be one that isn't focused.
        center = '', exec, playerctl --player="$(playerctl -l | head -n 1)" '';
      in [
        ",XF86AudioPrev${center}previous"
        ",XF86AudioNext${center}next"

        # this binds both play and pause to play-pause
        # since my headphones alternates which one it sends
        # if this is a problem (e.g you actually have and use
        # two specific play/pause buttons) then you might want
        # to change this
        ",XF86AudioPlay${center}play-pause"
        ",XF86AudioPause${center}play-pause"
      ];

    bind = let
      mkScreenshotBind = let
        date = ''$(date "+%Y-%m-%-d_%H:%M:%S")'';
      in
        # If we dont export that grimblast tries to create a new headless
        # display to take the image on for some reason.
        # That breaks ags and messes upp the display.
        # Disabling it seams to have no effect on the image
        core: ''mkdir images; GRIMBLAST_HIDE_CURSOR=1 grimblast ${core} "images/${date}.png"'';
    in [
      # old screen shot
      # deps: grim, slurp
      # ", Print, exec, grim -g \"$(slurp -w 0)\" - | wl-copy"

      # manual select
      '', Print, exec, ${mkScreenshotBind "--freeze copysave area"}''
      # current window
      ''SHIFT, Print, exec, ${mkScreenshotBind "copysave output"}''
      # current screen
      ''SHIFT, Print, exec, ${mkScreenshotBind "copysave output"}''
      # all screens
      ''CTRL, Print, exec, ${mkScreenshotBind "copysave screen"}''
    ];

    # kbd binds
    # they work in vms / cant be overridden by programs
    bindp = builtins.concatLists [
      [
        "$mod, P, exec, color-pick"

        # "$mod, Q, exec, kitty"
        "$mod, S, exec, $TERMINAL"
        "$mod, Return, exec, $TERMINAL"
        "$mod, D, exec, rofi -show drun"
        "$mod, F, exec, $BROWSER"
        "$mod, Escape, exec, hyprlock --immediate --immediate-render"

        "$mod, C, killactive"
        "$mod, M, exit"

        "$mod, U, togglefloating"
        "$mod, I, fullscreen, 0" # entire display

        # "$mod, F, exec, firefox"
        # ", Print, exec, grimblast copy area"
      ]

      (mkArrowBind "" "movefocus")
      (mkArrowBind "CTRL" "movewindow")
      (mkArrowBind "SHIFT" "swapwindow")

      # move active to workspace n, (preserve window focus)
      (genNumKeysBins (nb: wn: "$mod CTRL, ${nb}, movetoworkspace, ${wn}"))
      # throw active to workspace n, (preserve workspace focus)
      (genNumKeysBins (nb: wn: "$mod ALT, ${nb}, movetoworkspacesilent, ${wn}"))
      # switch current workspace with workspace n
      (genNumKeysBins (nb: wn: "$mod, ${nb}, focusworkspaceoncurrentmonitor, ${wn}"))
    ];
  };
}
