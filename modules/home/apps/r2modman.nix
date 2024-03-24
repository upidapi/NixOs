{
  config,
  pkgs,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.apps.r2modman;
in {
  options.modules.home.apps.r2modman = mkEnableOpt "Whether or not to enable r2modman.";

  config = mkIf cfg.enable {
    home.packages = [pkgs.r2modman];
  };
}
