{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.other;
in {
  options.modules.nixos.other =
    mkEnableOpt "enables config that i've not found a place for";

  config = mkIf cfg.enable {
    services.fwupd = enable;
  };
}
