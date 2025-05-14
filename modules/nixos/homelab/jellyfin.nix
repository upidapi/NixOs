{
  config,
  lib,
  my_lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt enable;
  cfg = config.modules.nixos.homelab.jellyfin;

  domainJellyfin = "jellyfin.upidapi.dev";
  portJellyfin = 8096;
  # domainRadarr = "radarr.upidapi.dev";
  # portRadarr = 7878;
  # domainSonarr = "sonarr.upidapi.dev";
  # portSonarr = 8989;
  # domainJackett = "jackett.upidapi.dev";
  # portJackett = 9117;
  # domainBazarr = "bazarr.upidapi.dev";
  # portBazarr = config.services.bazarr.listenPort; # 6767
  #
  # bazarrDirectory = "/var/lib/bazarr";
  #
  # diskstationAddress = "192.168.1.4";
  # mediaGroup = "diskstation-media";
  #
  # transmissionGroup = config.services.transmission.group;
in {
  options.modules.nixos.homelab.jellyfin =
    mkEnableOpt
    "enables jellyfin for local movie hosting";

  # REF: https://github.com/diogotcorreia/dotfiles/blob/db6db718a911c3a972c8b8784b2d0e65e981c770/hosts/hera/jellyfin.nix#L75
  config = mkIf cfg.enable {
    services = {
      jellyfin = enable;
      # radarr = enable;
      # sonarr = enable;
      # jackett = enable;
      # bazarr = enable;
      caddy.virtualHosts."jellyfin.upidapi.dev".extraConfig = ''
        encode zstd gzip

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

        @notblacklisted {
          not {
            path /metrics*
          }
        }

        reverse_proxy @notblacklisted http://localhost:8096
      '';
    };

    # users.groups.${mediaGroup} = {};
    users.users = {
      # ${config.services.radarr.user}.extraGroups = [mediaGroup transmissionGroup];
      # ${config.services.sonarr.user}.extraGroups = [mediaGroup transmissionGroup];
      # ${config.services.bazarr.user}.extraGroups = [mediaGroup];
    };

    /*
    services.caddy.virtualHosts = {
      ${domainJellyfin} = {
        # enableACME = true;
        extraConfig = ''
          reverse_proxy localhost:${toString portJellyfin}
        '';
      };
    };
    */
  };
}
