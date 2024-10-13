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
    networking.firewall.allowedTCPPorts = [80 443];

    # EXP: https://github.com/diogotcorreia/dotfiles/blob/db6db718a911c3a972c8b8784b2d0e65e981c770/profiles/services/caddy/common.nix#L2

    /*
       for opening to the internet
    networking.firewall = {
        allowedTCPPorts = [ 80 443 ];
        allowedUDPPorts = [ 443 ];
    };
    */
    services.caddy = {
      enable = true;
      virtualHosts = {
        "test".extraConfig = ''
          respond "Hello, world!"
        '';
        "test.dev".extraConfig = ''
          respond "Hello, world!"
        '';
        "test.com".extraConfig = ''
          respond "Hello, world!"
        '';
        "test.upidapi.dev".extraConfig = ''
          respond "Hello, world!"
        '';
      };
    };

    # Ensure nginx isn't turned on by some services (e.g. services using PHP)
    # services.nginx.enable = lib.mkForce false;
  };
}
