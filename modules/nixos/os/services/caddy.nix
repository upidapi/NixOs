{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt enable;
  cfg = config.modules.nixos.os.services.caddy;
in {
  options.modules.nixos.os.services.caddy =
    mkEnableOpt
    "enable caddy, a web server with auto certs";

  config = mkIf cfg.enable {
    /*
       for opening to the internet
    networking.firewall = {
        allowedTCPPorts = [ 80 443 ];
        allowedUDPPorts = [ 443 ];
    };
    */
    services.caddy = enable;
  };
}
