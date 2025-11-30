{
  lib,
  config,
  mlib,
  pkgs,
  ...
}: let
  inherit (mlib) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.networking.iphone-tethering;
in {
  options.modules.nixos.networking.iphone-tethering =
    mkEnableOpt "enables iphone tethering";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libimobiledevice
    ];

    services.usbmuxd = enable;
  };
}
