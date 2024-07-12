{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.os.networking.default;
in {
  options.modules.nixos.os.networking.default = mkEnableOpt "enables networking for the system";

  imports = [
    ./firewall
    ./openssh.nix
  ];
  config = mkIf cfg.enable {
    networking.hostName = config.modules.nixos.meta.host-name;
    # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking

    networking.networkmanager.enable = true;
  };
}
