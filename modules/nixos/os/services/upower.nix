{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.os.services.upower;
in {
  options.modules.nixos.os.services.upower = mkEnableOpt "battery info";

  config = mkIf cfg.enable {
    services.upower.enable = true;
  };
}
