{
  config,
  lib,
  mlib,
  const,
  ...
}: let
  inherit (const) ports ips;
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.homelab.media;
in {
  options.modules.nixos.homelab.media = mkEnableOpt "";

  # NOTE: port forward with ssh
  #  ssh -L 8192:localhost:8191 ssh.upidapi.dev -N

  # TODO: could add groups to users instead of putting it all in media
  imports = [
    ./declarr.nix
    ./autobrr
    ./cross-seed.nix
    ./jellyseerr.nix
    ./jellyfin
    # ./jellarr
    # ./jellarr.nix
    ./unpackerr
    ./qbit
    ./user-options.nix
    ./profilarr.nix
    # remove once these get merged
    # https://github.com/NixOS/nixpkgs/pull/287923
    # https://github.com/fsnkty/nixpkgs/pull/3
  ];

  # NOTE: if the jellyfin data is removed after jellyseerr is setup you
  #  get a bunch of errors (eg missing id)

  # REF: https://github.com/diogotcorreia/dotfiles/blob/db6db718a911c3a972c8b8784b2d0e65e981c770/hosts/hera/jellyfin.nix#L75
  config = mkIf cfg.enable {
    systemd.tmpfiles.settings = {
      "media-dir-create" = {
        "/raid/media".d = {
          group = "media";
          mode = "751";
        };

        "/raid/media/usenet".d = {
          group = "media";
          mode = "751";
        };
        "/raid/media/usenet".Z = {
          group = "media";
          mode = "751";
        };

        "/raid/media/movies".d = {
          user = "radarr";
          group = "media";
          mode = "771";
        };
        "/raid/media/movies".Z = {
          user = "radarr";
          group = "media";
          mode = "771";
        };
        # "/raid/media/subtitles".d = {
        #   group = "media";
        #   user = "bazarr";
        #   mode = "751";
        # };
        "/raid/media/tv".d = {
          user = "sonarr";
          group = "media";
          mode = "771";
        };
        "/raid/media/tv".Z = {
          user = "sonarr";
          group = "media";
          mode = "771";
        };

        "/raid/media/music".d = {
          user = "lidarr";
          group = "media";
          mode = "771";
        };
        "/raid/media/music".Z = {
          user = "lidarr";
          group = "media";
          mode = "771";
        };
      };
    };

    users.groups.media = {};

    services = {
      flaresolverr = {
        enable = true;
        port = ports.flaresolverr;
        # openFirewall = true;
      };
      # module from https://github.com/undefined-landmark/nixpkgs/blob/default-serverConfig/nixos/modules/services/torrent/qbittorrent.nix
      jackett = {
        enable = true;
        port = ports.jackett;
      };
      bazarr = {
        group = "media";
        enable = true;
        listenPort = ports.bazarr;
      };
      caddy.virtualHosts = {
        "sonarr.upidapi.dev".extraConfig = ''
          reverse_proxy :${toString ports.sonarr}
        '';
        "radarr.upidapi.dev".extraConfig = ''
          reverse_proxy :${toString ports.radarr}
        '';
        "prowlarr.upidapi.dev".extraConfig = ''
          reverse_proxy :${toString ports.prowlarr}
        '';

        "autobrr.upidapi.dev".extraConfig = ''
          reverse_proxy :${toString ports.autobrr}
        '';

        # "cross-seed.upidapi.dev".extraConfig = ''
        #   reverse_proxy :${toString ports.cross-seed}
        # '';
        "qbit.upidapi.dev".extraConfig = ''
          reverse_proxy ${ips.proton}:${toString ports.qbit}
        '';

        "jellyseerr.upidapi.dev".extraConfig = ''
          reverse_proxy :${toString ports.jellyseerr}

          header {
            # 1. Strip the default restrictive headers sent by the backend
            -X-Frame-Options
          
            # 2. Apply the correct CSP to allow framing exclusively by your domains
            +Content-Security-Policy "frame-ancestors https://jellyfin.upidapi.dev https://*.upidapi.dev;"
          }
        '';
        "jellyfin.upidapi.dev".extraConfig = ''
          encode zstd gzip

          import harden_headers

          @notblacklisted {
            not {
              path /metrics*
            }
          }

          reverse_proxy @notblacklisted :${toString ports.jellyfin}
        '';
      };
    };
  };
}
