{...}: {
  wayland.windowManager.hyprland.settings = {
    exec-once = ["bash ${./exec-once.sh}"];

    general = {
      gaps_in = 0;
      gaps_out = 0;
    };

    # layout
    input = {
      kb_layout = "se"; # swedish layout

      touchpad = {
        natural_scroll = true;
        scroll_factor = 0.5;
        # disable_while_typing = false;
      };
    };
  };
}
