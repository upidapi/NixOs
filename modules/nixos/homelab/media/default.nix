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

  imports = [
    ./jellyfin.nix
    # remove once these get merged
    # https://github.com/NixOS/nixpkgs/pull/287923
    # https://github.com/fsnkty/nixpkgs/pull/3
    "${inputs.qbit}/nixos/modules/services/torrent/qbittorrent.nix"
  ];

  # REF: https://github.com/diogotcorreia/dotfiles/blob/db6db718a911c3a972c8b8784b2d0e65e981c770/hosts/hera/jellyfin.nix#L75
  config = mkIf cfg.enable {
    systemd.tmpfiles.settings = {
      "media-dir-create" = {
        "/srv/jellyfin".d = {
          group = "media";
          user = "jellyfin";
          mode = "751";
        };
        "/srv/radarr".d = {
          group = "media";
          user = "radarr";
          mode = "751";
        };
        "/srv/bazarr".d = {
          group = "media";
          user = "bazarr";
          mode = "751";
        };
        "/srv/sonarr".d = {
          group = "media";
          user = "sonarr";
          mode = "751";
        };
      };
    };

    users.groups.media = {};
    users.users = {
      ${config.services.radarr.user}.extraGroups = ["media"];
      ${config.services.sonarr.user}.extraGroups = ["media"];
      ${config.services.bazarr.user}.extraGroups = ["media"];
      ${config.services.jellyfin.user}.extraGroups = ["media"];
    };

    services = {
      flaresolverr = {
        enable = true;
        port = ports.flaresolverr;
        # openFirewall = true;
      };
      qbittorrent = {
        enable = true;
        package = inputs.qbit.legacyPackages.${pkgs.system}.qbittorrent-nox;
        serverConfig.LegalNotice.Accepted = true;
      };
      # https://www.rapidseedbox.com/blog/jellyseerr-guide#01
      jellyseerr = {
        enable = true;
        port = ports.jellyseerr;
        # openFirewall = true;
      };
      prowlarr = {
        enable = true;
        settings = {
          # update.mechanism = "internal";
          server = {
            urlbase = "localhost";
            port = ports.prowlarr;
            bindaddress = "*";
          };
        };
      };
      radarr = {
        enable = true;
        group = "media";
        settings = {
          # update.mechanism = "internal";
          server = {
            # urlbase = "localhost";
            port = ports.radarr;
            # bindaddress = "*";
          };
        };
      };
      sonarr = {
        enable = true;
        group = "media";
        settings = {
          # update.mechanism = "internal";
          server = {
            # urlbase = "localhost";
            port = ports.sonarr;
            # bindaddress = "*";
          };
        };
      };
      jackett = {
        enable = true;
        port = ports.jackett;
      };
      bazarr = {
        group = "media";
        enable = true;
        listenPort = ports.bazarr;
      };
    };
  };
}
