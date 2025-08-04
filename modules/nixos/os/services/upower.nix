{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib.opt) mkEnableOpt;
  cfg = config.modules.nixos.os.services.upower;
in {
  options.modules.nixos.os.services.upower = mkEnableOpt "battery info";

  config = mkIf cfg.enable {
    services.upower.enable = true;
  };
}
