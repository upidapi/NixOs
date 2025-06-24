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
    ./dec2.nix
    # remove once these get merged
    # https://github.com/NixOS/nixpkgs/pull/287923
    # https://github.com/fsnkty/nixpkgs/pull/3
    "${inputs.qbit}/nixos/modules/services/torrent/qbittorrent.nix"
  ];

  # TODO: maybe don't change group of things
  #  instead of adding everything shared into media
  #  eg add the sonarr group to the jellyfin user

  # REF: https://github.com/diogotcorreia/dotfiles/blob/db6db718a911c3a972c8b8784b2d0e65e981c770/hosts/hera/jellyfin.nix#L75
  config = mkIf cfg.enable {
    systemd.tmpfiles.settings = {
      "media-dir-create" = {
        # "/srv/jellyfin".d = {
        #   group = "media";
        #   user = "jellyfin";
        #   mode = "751";
        # };
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
          user = "qbittorrent";
          mode = "751";
        };
      };
    };

    sops.secrets = {
      "qbit/password_sonarr" = {
        key = "qbit/password";
        owner = config.services.sonarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
      "qbit/password_radarr" = {
        key = "qbit/password";
        owner = config.services.radarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
      "qbit/password_prowlarr" = {
        key = "qbit/password";
        owner = config.services.prowlarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
      "radarr/password" = {
        owner = config.services.radarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
      "radarr/api-key" = {
        owner = config.services.radarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
      "radarr/api-key_prowlarr" = {
        key = "radarr/api-key";
        owner = config.services.prowlarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
      "sonarr/password" = {
        owner = config.services.sonarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
      "sonarr/api-key" = {
        owner = config.services.sonarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
      "sonarr/api-key_prowlarr" = {
        key = "sonarr/api-key";
        owner = config.services.prowlarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
      "prowlarr/password" = {
        owner = config.services.prowlarr.user;
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
        PROWLARR__AUTH__APIKEY=${config.sops.placeholder."prowlarr/api-key"}
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
      prowlarr = {
        enable = true;
        environmentFiles = [config.sops.templates."prowlarr-env".path];
        apiKeyFile = config.sops.secrets."prowlarr/api-key".path;
        settings = {
          # update.mechanism = "internal";
          server = {
            urlbase = "localhost";
            port = ports.prowlarr;
            bindaddress = "*";
          };
        };
        extraSettings = {
          host = {
            username = "admin";
            password = config.sops.secrets."prowlarr/password".path;
            apiKey = config.sops.secrets."prowlarr/api-key".path;
          };
          downloadClients = {
            "qBittorrent" = {
              implementation = "QBittorrent";
              fields = {
                port = ports.qbit;
                username = "admin";
                password = config.sops.secrets."qbit/password_prowlarr".path;
                sequentialOrder = true;
              };
            };
          };
          indexerProxies = {
            "FlareSolverr" = {
              fields = {
                host = "http://localhost:8191/";
                requestTimeout = 60;
              };
              tags = ["FlareSolverr"];
            };
          };
          indexers = {
            "1337x" = {
              implementation = "Cardigann";
              fields = {
                definitionFile = "1337x";
                downloadlink = 1; # magnet
                downloadlink2 = 0; # iTorrents.org
                sort = 2; # created
                type = 1; # desc
              };
              tags = ["FlareSolverr"];
            };
            "AnimeTosho" = {
              implementation = "Torznab";
              fields = {
                baseUrl = "https://feed.animetosho.org";
              };
            };
            "LimeTorrents" = {
              implementation = "Cardigann";
              fields = {
                definitionFile = "limetorrents";
                downloadlink = 1; # magnet
                downloadlink2 = 0; # iTorrents.org
                sort = 0; # created
              };
            };
            # "Solid Torrents" = {
            #   implementation = "Cardigann";
            #   fields = {
            #     definitionFile = "solidtorrents";
            #     prefer_magnet_links = true;
            #     sort = 0; # created
            #     type = 1; # desc
            #   };
            # };
            "The Pirate Bay" = {
              implementation = "Cardigann";
              fields = {
                definitionFile = "thepiratebay";
              };
            };
            "TheRARBG" = {
              implementation = "Cardigann";
              fields = {
                definitionFile = "therarbg";
                sort = 0; # created desc
              };
            };
            "YTS" = {
              implementation = "Cardigann";
              fields = {
                definitionFile = "yts";
              };
            };
          };
          applications = {
            "Sonarr" = {
              syncLevel = "fullSync";
              implementation = "Sonarr";
              fields.apiKey = config.sops.secrets."sonarr/api-key_prowlarr".path;
            };
            "Radarr" = {
              syncLevel = "fullSync";
              implementation = "Radarr";
              fields.apiKey = config.sops.secrets."radarr/api-key_prowlarr".path;
            };
          };
        };
      };
      radarr = {
        enable = true;
        group = "media";
        environmentFiles = [config.sops.templates."radarr-env".path];
        apiKeyFile = config.sops.secrets."radarr/api-key".path;
        settings = {
          # update.mechanism = "internal";
          server = {
            # urlbase = "localhost";
            port = ports.radarr;
            # bindaddress = "*";
          };
        };
        extraSettings = {
          host = {
            username = "admin";
            password = config.sops.secrets."radarr/password".path;
            apiKey = config.sops.secrets."radarr/api-key".path;
          };
          rootFolders = ["/srv/radarr"];
          downloadClients = {
            "qBittorrent" = {
              implementation = "QBittorrent";
              fields = {
                port = ports.qbit;
                username = "admin";
                password = config.sops.secrets."qbit/password_radarr".path;
                sequentialOrder = true;
              };
            };
          };
        };
      };
      sonarr = {
        enable = true;
        group = "media";
        environmentFiles = [config.sops.templates."sonarr-env".path];
        apiKeyFile = config.sops.secrets."sonarr/api-key".path;
        settings = {
          # update.mechanism = "internal";
          server = {
            # urlbase = "localhost";
            port = ports.sonarr;
            # bindaddress = "*";
          };
        };
        extraSettings = {
          host = {
            # TODO: make these required via assertions
            username = "admin";
            password = config.sops.secrets."sonarr/password".path;
          };
          rootFolders = ["/srv/sonarr"];
          downloadClients = {
            "qBittorrent" = {
              implementation = "QBittorrent";
              fields = {
                port = ports.qbit;
                username = "admin";
                password = config.sops.secrets."qbit/password_sonarr".path;
                sequentialOrder = true;
              };
            };
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
