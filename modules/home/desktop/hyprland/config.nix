{
  wayland.windowManager.hyprland.settings = {
    debug = {
      disable_logs = false;
      error_position = 1; # bottom
    };
    ecosystem = {
      no_update_news = true;
      no_donation_nag = true;
    };
    misc = {
      # when you create a new windows while you have a maximised window
      # then its unmaximised
      new_window_takes_over_fullscreen = 2;

      middle_click_paste = false;

      disable_hyprland_logo = true;
      disable_splash_rendering = true;

      # idk
      mouse_move_enables_dpms = true;
      key_press_enables_dpms = true;
      allow_session_lock_restore = true;
    };

    general = {
      gaps_in = 0;
      gaps_out = 0;
    };

    # layout
    input = {
      kb_layout = "gb,se";
      kb_options = "compose:menu, grp:alt_space_toggle";

      # faster and less delay for the repeating
      # of keypresses when held down
      repeat_delay = 300;
      repeat_rate = 50;

      touchpad = {
        natural_scroll = true;
        scroll_factor = 0.5;
        disable_while_typing = true;
      };
    };

    # disable animations for the images (that are actually
    # wayland windows) created by ueberzugpp
    windowrulev2 = "noanim, title:ueberzugpp";

    animations = {
      enabled = "yes";
      animation = [
        "workspaces, 0"
        "fade, 0"
      ];
    };
  };
}
