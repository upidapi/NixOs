{
  config,
  lib,
  my_lib,
  ports,
  inputs,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.homelab.media;
in {
  options.modules.nixos.homelab.media = mkEnableOpt "";

  # NOTE: port forward with ssh
  #  ssh -L 8192:localhost:8191 ssh.upidapi.dev -N

  # TODO: limit download bitrate (i dont wana 90 GB 1080p)

  imports = [
    ./arr
    ./jellyseerr
    ./user-options.nix
    ./jellyfin
    ./qbit
    # remove once these get merged
    # https://github.com/NixOS/nixpkgs/pull/287923
    # https://github.com/fsnkty/nixpkgs/pull/3
    "${inputs.qbit}/nixos/modules/services/torrent/qbittorrent.nix"
  ];

  # TODO: maybe don't change group of things
  #  instead of adding everything shared into media
  #  eg add the sonarr group to the jellyfin user

  # NOTE: if the jellyfin data is removed after jellyseerr is setup you
  #  get a bunch of errors (eg missing id)

  # REF: https://github.com/diogotcorreia/dotfiles/blob/db6db718a911c3a972c8b8784b2d0e65e981c770/hosts/hera/jellyfin.nix#L75
  config = mkIf cfg.enable {
    systemd.tmpfiles.settings = {
      "media-dir-create" = {
        "/media".d = {
          group = "media";
          mode = "751";
        };
        "/media/torrents".d = {
          group = "media";
          user = "qbittorrent";
          mode = "751";
        };
        "/media/torrents".Z = {
          group = "media";
          user = "qbittorrent";
          mode = "751";
        };
        "/media/usenet".d = {
          group = "media";
          mode = "751";
        };
        "/media/usenet".Z = {
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

        "qbit.upidapi.dev".extraConfig = ''
          reverse_proxy :${toString ports.qbit}
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
