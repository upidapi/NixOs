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
    networking.firewall.allowedTCPPorts = [
      7071 # for azure func api
      7072 # if you want 2
      8081 # for app
    ];
  };
}
