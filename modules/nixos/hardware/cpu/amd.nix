{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.hardware.cpu.amd;
in {
  options.modules.nixos.hardware.cpu.amd =
    mkEnableOpt "enables amd cpu drivers for the system";

  config = mkIf cfg.enable {
    # todo: what is this?
    services.xserver.videoDrivers = ["modesetting"];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
