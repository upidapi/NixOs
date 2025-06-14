{
  config,
  lib,
  my_lib,
  ports,
  inputs,
  pkgs,
  self,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.homelab.media;
in {
  options.modules.nixos.homelab.media = mkEnableOpt "";

  imports = [
    # ./jellyfin.nix
    ./jellyfin-dec.nix
    ./jellyseerr
    ./base.nix
    # remove once these get merged
    # https://github.com/NixOS/nixpkgs/pull/287923
    # https://github.com/fsnkty/nixpkgs/pull/3
    "${inputs.qbit}/nixos/modules/services/torrent/qbittorrent.nix"
  ];

  # TODO: maybe don't change group of things
  #  instead of adding everything shared into media
  #  eg add the sonarr group to the jellyfin user

  # REF: https://github.com/diogotcorreia/dotfiles/blob/db6db718a911c3a972c8b8784b2d0e65e981c770/hosts/hera/jellyfin.nix#L75
  config =
    mkIf cfg.enable {
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
          "/srv/qbit".d = {
            group = "media";
            user = "qbit";
            mode = "751";
          };
        };
      };

      sops.secrets = {
        "radarr/api-key" = {
          owner = config.services.radarr.user;
          sopsFile = "${self}/secrets/server.yaml";
        };
        "sonarr/api-key" = {
          owner = config.services.sonarr.user;
          sopsFile = "${self}/secrets/server.yaml";
        };
        "prowlarr/api-key" = {
          owner = config.services.prowlarr.user;
          sopsFile = "${self}/secrets/server.yaml";
        };
      };

      sops.templates = {
        "sonarr-env".content = ''
          SONARR__AUTH__APIKEY=${config.sops.placeholder."sonarr/api-key"}
        '';
        "radarr-env".content = ''
          RADARR__AUTH__APIKEY=${config.sops.placeholder."radarr/api-key"}
        '';
        "prowlarr-env".content = ''
          RADARR__AUTH__APIKEY=${config.sops.placeholder."prowlarr/api-key"}
        '';
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
          serverConfig = {
            LegalNotice.Accepted = true;
            BitTorrent.Session = {
              DefaultSavePath = "/srv/qbit";
              TempPath = "/srv/qbit/tmp";
            };
            Preferences.WebUI = {
              Username = "admin";

              # Use this to generate the password hash
              /*
              ITERATIONS=100000
              SALT_SIZE=16
              KEY_LEN=64

              get_hashed_password() {
                psw="$1"

                salt=$(head -c "$SALT_SIZE" /dev/urandom)
                salt_b64=$(echo -n "$salt" | openssl base64)

                hash=$(openssl kdf \
                  -kdfopt "pass:$psw" \
                  -kdfopt "digest:SHA512" \
                  -kdfopt "salt:$salt_b64" \
                  -kdfopt "iter:$ITERATIONS" \
                  -keylen "$KEY_LEN" \
                  -binary \
                  PBKDF2 \
                | openssl base64)

                echo "@ByteArray($salt_b64:$hash)"
              }

              get_hashed_password "your secret password"
              */
              Password_PBKDF2 = "@ByteArray(f7GqbV6L52bgyO+3oHz3fQ==:oI+W3h3yQ6yFIV1oZkEG7PsfM9TQ74oYvoozsTw1Y7Gi7FZa+oR3NoR2+ug8wJWv
JE083xBhyhXEpMn0G2a5Iw==)";
            };
          };
        };
        prowlarr = {
          enable = true;
          environmentFiles = [config.sops.templates."prowlarr-env".path];
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
          environmentFiles = [config.sops.templates."radarr-env".path];
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
          environmentFiles = [config.sops.templates."sonarr-env".path];
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
