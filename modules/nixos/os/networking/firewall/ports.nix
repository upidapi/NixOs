{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.os.networking.firewall.ports;
in {
  options.modules.nixos.os.networking.firewall.ports = mkEnableOpt "open some ports";

  config = mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [
        7071 # for azure func api
        7072
        8081

        # for dev things
        3500
        3501
        3502
        3503

        # for game servers
        6800
        6801
        6802
        6803
        6804
        6805
        6806
        6807
        6808
        6809
      ];
      allowedUDPPorts = [
        7071
        7072
        8081

        3500
        3501
        3502
        3503

        # for game servers
        6800
        6801
        6802
        6803
        6804
        6805
        6806
        6807
        6808
        6809
      ];
    };
  };
}
