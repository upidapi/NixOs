{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt enable;
  cfg = config.modules.home.apps.kitty;
in {
  options.modules.home.apps.kitty = mkEnableOpt "enable kitty, the terminal";

  config = mkIf cfg.enable {
    programs.kitty = enable;

    home.sessionVariables = {
      TERMINAL = "kitty";
    };
  };
}
