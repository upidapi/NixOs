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
    ./arr.nix
    ./autobrr
    ./cross-seed.nix
    ./jellyseerr.nix
    ./jellyfin
    ./unpackerr
    ./qbit
    ./user-options.nix
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
        "/raid/media/torrents".d = {
          group = "media";
          user = "qbittorrent";
          mode = "751";
        };
        "/raid/media/torrents".Z = {
          group = "media";
          user = "qbittorrent";
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
