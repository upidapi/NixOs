{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
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
        config = ''
          map ctrl+shift+r no_op

          # places the "characters" of the window to the top left
          # so it padds to the bottom-right
          placement_strategy top-left  # default center
        '';
        colorConfig = with config.lib.stylix.colors.withHashtag; ''
          #   # window colors
          #
          #   # bright (real)
          #   # color8 #{{base02-hex}}
          #   # color9 #{{base08-hex}}
          #   # color10 #{{base0B-hex}}
          #   # color11 #{{base0A-hex}}
          #   # color12 #{{base0D-hex}}
          #   # color13 #{{base0E-hex}}
          #   # color14 #{{base0C-hex}}
          #   # color15 #{{base07-hex}}
          # '';
      in
        colorConfig;
    };

    home.sessionVariables = {
      TERMINAL = "kitty";
    };
  };
}
