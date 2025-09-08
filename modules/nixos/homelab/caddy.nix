{
  config,
  lib,
  mlib,
  const,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt enable;
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

    # authelia - probably not worth it
    # nebula - maybe a bad idea

    services.caddy = {
      enable = true;
      # acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory";
      # logFormat = "level DEBUG";
      extraConfig = ''
        (harden_headers) {
          header {
            # Enable HTTP Strict Transport Security (HSTS)
            Strict-Transport-Security "max-age=31536000;"
            # Enable cross-site filter (XSS) and tell browser to block detected attacks
            X-XSS-Protection "1; mode=block"
            # Disallow the site to be rendered within a frame (clickjacking protection)
            X-Frame-Options "DENY"
            # Avoid MIME type sniffing
            X-Content-Type-Options "nosniff"
            # Prevent search engines from indexing (optional)
            X-Robots-Tag "none"
            # Server name removing
            -Server
          }
        }

        (authelia) {
          forward_auth localhost:9091 {
            uri /api/authz/forward-auth
            copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
          }
        }
      '';
      virtualHosts = {
        "upidapi.com".extraConfig = ''
          respond "Hello, world!"
        '';

        # TODO: move to .com
        "games.upidapi.dev".extraConfig = ''
          reverse_proxy :${toString const.ports.impostor}
        '';

        # "upidapi.dev".extraConfig = ''
        #   respond "Hello, world!"
        # '';

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
