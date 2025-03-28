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
<<<<<<< HEAD
    networking.firewall.allowedTCPPorts = [
      7071 # for azure func api
      7072 # if you want 2
      8081 # for app
    ];
||||||| parent of f55a2e2 (debug: ports)
    networking.firewall.allowedTCPPorts = [
      7071 # for azure func api
    ];
=======
    networking.firewall = {
      allowedTCPPorts = [
        7071 # for azure func api
        8081
        19000
        19001
        19002
      ];
      allowedUDPPorts = [
        7071
        8081
      ];
    };
>>>>>>> f55a2e2 (debug: ports)
  };
}
