{
  lib,
  config,
  mlib,
  pkgs,
  ...
}: let
  inherit (mlib) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.networking.iphone-tethering;
in {
  options.modules.nixos.os.networking.iphone-tethering =
    mkEnableOpt "enables iphone tethering";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libimobiledevice
    ];

    services.usbmuxd = enable;
  };
}
