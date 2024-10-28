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
    programs.kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;

        visual_bell_duration = 0;
        enable_audio_bell = "no";
        bell_on_tab = "no";
      };
    };

    home.sessionVariables = {
      TERMINAL = "kitty";
    };
  };
}
