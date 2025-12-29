{
  config,
  lib,
  mlib,
  const,
  self,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  inherit (const) ports;
  cfg = config.modules.nixos.homelab.services.thelounge;
in {
  options.modules.nixos.homelab.services.thelounge = mkEnableOpt "";

  imports = [
    ./base.nix
  ];

  # FROM: https://github.com/The1Penguin/nix_dots/blob/ab8352b2ad11488b41e08cc034fc4ea204b069a8/server/services/lounge.nix#L4
  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "irc.upidapi.dev".extraConfig = ''
        reverse_proxy :${toString ports.the-lounge}
      '';
    };

    # users:
    # /var/lib/thelounge/users/<name>.json
    # {
    #   "password": "$2a$11$FEpA5k6VqaQHTfZEUzBHOeoIws84cIipP6WY34yKCCKaZ0lLuoI2e",
    #   "log": true
    # }
    # psw: 1234
    # https://bcrypt-generator.com/

    sops.secrets."the-lounge/upidapi" = {
      owner = "thelounge";
      sopsFile = "${self}/secrets/server.yaml";
    };

    services.thelounge = {
      enable = true;
      port = ports.the-lounge;
      public = false;
      plugins = [];

      users = {
        upidapi = {
          logs = true;
          passwordFile = config.sops.secrets."the-lounge/upidapi".path;
        };
      };
      extraConfig = {
        reverseProxy = true;
        maxHistory = 100000;
        https.enable = false; # Reverse proxy enabled
        prefetch = true;
        prefetchStorage = false;
        prefetchMaxImageSize = 50000;
        prefetchMaxSearchSize = 900;
        fileUpload = {
          enable = true;
          maxFileSize = 50000;
        };
        # transports = ["websockets"];
        # defaults = {
        #   name = "Dtek.se";
        #   host = "irc.dtek.se";
        #   port = 6697;
        #   password = "";
        #   tls = true;
        #   rejectUnauthorized = false;
        #   nick = "anna";
        #   username = "";
        #   realname = "";
        #   join = "#dtek";
        #   leaveMessage = "";
        # };
      };
    };
  };
}
