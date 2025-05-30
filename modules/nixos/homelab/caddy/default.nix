{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt enable;
  cfg = config.modules.nixos.homelab.caddy;
in {
  options.modules.nixos.homelab.caddy =
    mkEnableOpt
    "enable caddy, a web server with auto certs";

  config = mkIf cfg.enable {
    # good resources
    #   https://github.com/diogotcorreia/dotfiles/blob/db6db718a911c3a972c8b8784b2d0e65e981c770/profiles/services/caddy/common.nix#L2

    # for opening to the internet
    networking.firewall = {
      allowedTCPPorts = [80 443];
      allowedUDPPorts = [443];
    };

    # TODO: add a page with liks to everything hosted on upidapi.dev at "upidapi.dev"

    # authelia - probably not worth it
    # nebula - maybe a bad idea

    services.caddy = {
      enable = true;
      # acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory";
      # logFormat = "level DEBUG";
      extraConfig = ''

      '';
      virtualHosts = {
        "upidapi.com".extraConfig = ''
          respond "Hello, world!"
        '';

        "upidapi.dev".extraConfig = ''
          respond "Hello, world!"
        '';

        # "http://upidapi.com".extraConfig = ''
        #   respond "Hello, world!"
        # '';

        /*
        "localhost.dev".extraConfig = ''
          respond "Hello, world!"
        '';
        "localhost.com".extraConfig = ''
          respond "Hello, world!"
        '';
        "localhost.upidapi.dev".extraConfig = ''
          respond "Hello, world!"
        '';
        */
      };
    };

    # Ensure nginx isn't turned on by some services (e.g. services using PHP)
    # services.nginx.enable = lib.mkForce false;
  };
}
