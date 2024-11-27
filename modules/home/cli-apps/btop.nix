{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.cli-apps.btop;
in {
  options.modules.home.cli-apps.btop =
    mkEnableOpt "Whether or not to add btop for system monitoring";

  config = mkIf cfg.enable {
    programs.btop = {
      enable = true;
      settings = {
        vim_keys = true;
        update_ms = 200;
      };
    };
  };
}
