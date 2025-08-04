{
  config,
  pkgs,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib.opt) mkEnableOpt;
  cfg = config.modules.home.apps.r2modman;
in {
  options.modules.home.apps.r2modman = mkEnableOpt "Whether or not to enable r2modman.";

  config = mkIf cfg.enable {
    home.packages = [pkgs.r2modman];
  };
}
