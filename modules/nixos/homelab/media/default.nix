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
    ./arr
    ./jellyseerr
    ./user-options.nix
    ./jellyfin.nix
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
        "/srv/qbit".d = {
          group = "media";
          user = "qbittorrent";
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
      qbittorrent = {
        enable = true;
        group = "media";
        package = inputs.qbit.legacyPackages.${pkgs.system}.qbittorrent-nox;
        serverConfig = {
          LegalNotice.Accepted = true;
          BitTorrent.Session = {
            DefaultSavePath = "/srv/qbit";
            TempPath = "/srv/qbit/tmp";
          };
          Preferences.WebUI = {
            Port = ports.qbit;
            Username = "admin";

            # Use this to generate the password hash
            /*
            #!/usr/bin/env nix-shell
            #!nix-shell -i real-interpreter -p openssl -p xxd

            set -euo pipefail

            SALT_BYTES=16
            KEY_LEN_BYTES=64
            ITERATIONS=100000
            DIGEST_ALGO="SHA512"

            get_hashed_password () {
              PASSWORD="$1"

              SALT_HEX=$(
                openssl rand "$SALT_BYTES" \
                | xxd -p -c 256 \
                | tr -d '\n'
              )

              SALT_B64=$(
                echo -n "$SALT_HEX" \
                | xxd -r -p \
                | base64 \
                | tr -d '\n='
              )

              DERIVED_KEY_B64=$(openssl kdf \
                  -keylen "$KEY_LEN_BYTES" \
                  -kdfopt digest:"$DIGEST_ALGO" \
                  -kdfopt pass:"$PASSWORD" \
                  -kdfopt hexsalt:"$SALT_HEX" \
                  -kdfopt iter:"$ITERATIONS" \
                  -binary \
                  PBKDF2 \
                  | base64 \
                  | tr -d '\n=')


              echo "${SALT_B64}==:${DERIVED_KEY_B64}=="
            }

            get_hashed_password "your secret password"
            */
            Password_PBKDF2 = "@ByteArray(TZ2O65dP76xf7p9U8tC4mg==:rEf5zTudNuXk7f8gjPjdZaigeFgRkxK1Gvn/YM4BOb3uHInTOTHJI1BS1pzdBHWrbwM0TG0ehFFRodb/DNp2Kw==)";
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
