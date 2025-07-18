{
  lib,
  config,
  my_lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
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
