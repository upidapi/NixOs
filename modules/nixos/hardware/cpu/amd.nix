{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib.opt) mkEnableOpt;
  cfg = config.modules.nixos.hardware.cpu.amd;
in {
  options.modules.nixos.hardware.cpu.amd =
    mkEnableOpt "enables amd cpu drivers for the system";

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = ["modesetting"];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
