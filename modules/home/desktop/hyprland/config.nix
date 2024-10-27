{
  wayland.windowManager.hyprland.settings = {
    debug.disable_logs = false;

    misc = {
      # when you create a new windows while you have a maximised window
      # then its unmaximised
      new_window_takes_over_fullscreen = 2;

      middle_click_paste = false;

      # idk
      # mouse_move_enables_dpms = true;
      # key_press_enables_dpms = true;
      allow_session_lock_restore = true;
    };

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

    # disable animations for the images (that are actually
    # wayland windows) created by ueberzugpp
    windowrulev2 = "noanim, title:ueberzugpp";
  };
}
