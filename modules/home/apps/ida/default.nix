{
  config,
  lib,
  mlib,
  self',
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.apps.ida;
in {
  options.modules.home.apps.ida = mkEnableOpt "";

  config = mkIf cfg.enable {
    home.packages = [
      self'.packages.ida-pro
    ];
  };
}
