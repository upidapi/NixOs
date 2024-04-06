{
  lib,
  my_lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.hardware.network;
in {
  options.modules.nixos.hardware.network =
    mkEnableOpt "enables networking for the system";

  config = mkIf cfg.enable {
    networking.hostName = config.modules.nixos.host-name;

    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking

    networking.networkmanager.enable = true;
  };
}
