{
  config,
  lib,
  my_lib,
  ports,
  self,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.homelab.media.arr;
in {
  options.modules.nixos.homelab.media.arr = mkEnableOpt "";

  imports = [
    ./base.nix
  ];

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings = {
      "media-dir-create" = {
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

    users.users = {
      ${config.services.radarr.user}.extraGroups = ["media"];
      ${config.services.sonarr.user}.extraGroups = ["media"];
      ${config.services.bazarr.user}.extraGroups = ["media"];
      ${config.services.jellyfin.user}.extraGroups = ["media"];
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

    services = {
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
    };
  };
}
