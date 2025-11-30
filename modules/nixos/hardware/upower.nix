{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.hardware.upower;
in {
  options.modules.nixos.hardware.upower = mkEnableOpt "battery info";

  config = mkIf cfg.enable {
    services.upower.enable = true;
  };
}
