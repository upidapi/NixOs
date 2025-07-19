{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.os.networking.firewall.ports;
in {
  options.modules.nixos.os.networking.firewall.ports = mkEnableOpt "open some ports";

  config = mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [
        7071 # for azure func api
        7072
        8081
        19000
        19001
        19002
      ];
      allowedUDPPorts = [
        7071
        7072
        8081
      ];
    };
  };
}
