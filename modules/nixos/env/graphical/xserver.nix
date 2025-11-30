{
  config,
  mlib,
  lib,
  ...
}: let
  inherit (mlib) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.env.graphical.xserver;
in {
  options.modules.nixos.env.graphical.xserver =
    mkEnableOpt "enables the xserver";

  config = mkIf cfg.enable {
    services = {
      xserver = enable;
    };
  };
}
