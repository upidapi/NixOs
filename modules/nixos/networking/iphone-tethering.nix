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

  # nmcli device connect enp14s0u1c4i2
  # then disconnect the other wired network
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libimobiledevice
    ];

    services.usbmuxd = enable;
  };
}
