{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.apps.kitty;
in {
  options.modules.home.apps.kitty = mkEnableOpt "enable kitty, the terminal";

  config = mkIf cfg.enable {
    stylix.targets.kitty.enable = false;

    programs.kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;

        visual_bell_duration = 0;
        enable_audio_bell = "no";
        bell_on_tab = "no";

        background_opacity = "${
          builtins.toString
          config.stylix.opacity.terminal
        }";
      };

      # usually done by stylix, but since we want a custom theme
      # we have to readd this manually
      font = {
        inherit (config.stylix.fonts.monospace) package name;
        size = config.stylix.fonts.sizes.terminal;
      };

      extraConfig = let
        kittyConfig = ''
          map ctrl+shift+r no_op

          # places the "characters" of the window to the top left
          # so it padds to the bottom-right
          # default center
          placement_strategy top-left

          # you can scroll with ctrl + shift + arrow upp/down/end/home

          # dont show the paste promt
          paste_actions filter
        '';
        colorConfig = with config.lib.stylix.colors.withHashtag; ''
          # window colors
          background ${base00}
          foreground ${base05}
          selection_background ${base03}
          selection_foreground ${base05}
          url_color ${base04}
          cursor ${base05}
          cursor_text_color ${base00}
          active_border_color ${base03}
          inactive_border_color ${base01}
          active_tab_background ${base00}
          active_tab_foreground ${base05}
          inactive_tab_background ${base01}
          inactive_tab_foreground ${base04}
          tab_bar_background ${base01}
          wayland_titlebar_color ${base00}
          macos_titlebar_color ${base00}

          # text colors
          color0 ${base00}
          color1 ${base08}
          color2 ${base0B}
          color3 ${base0A}
          color4 ${base0D}
          color5 ${base0E}
          color6 ${base0C}
          color7 ${base05}

          # bright text colors
          color8 ${base00}
          color9 ${base08}
          color10 ${base0B}
          color11 ${base0A}
          color12 ${base0D}
          color13 ${base0E}
          color14 ${base0C}
          color15 ${base05}

          # bright (real)
          # color8 #{{base02-hex}}
          # color9 #{{base08-hex}}
          # color10 #{{base0B-hex}}
          # color11 #{{base0A-hex}}
          # color12 #{{base0D-hex}}
          # color13 #{{base0E-hex}}
          # color14 #{{base0C-hex}}
          # color15 #{{base07-hex}}
        '';
      in
        kittyConfig + colorConfig;
    };
  };
}
