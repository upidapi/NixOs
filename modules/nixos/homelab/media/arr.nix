{
  config,
  lib,
  mlib,
  const,
  self,
  inputs,
  ...
}: let
  inherit (const) ports ips;
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.homelab.media.arr;
in {
  options.modules.nixos.homelab.media.arr = mkEnableOpt "";

  imports = [
    inputs.declarative-arr.nixosModules.default
  ];

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings = {
      "media-dir-create" = {
        "/media/movies".d = {
          group = "media";
          user = "radarr";
          mode = "751";
        };
        "/media/movies".Z = {
          group = "media";
          user = "radarr";
          mode = "751";
        };
        # "/media/subtitles".d = {
        #   group = "media";
        #   user = "bazarr";
        #   mode = "751";
        # };
        "/media/tv".d = {
          group = "media";
          user = "sonarr";
          mode = "751";
        };
        "/media/tv".Z = {
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
      ${config.services.jellyseerr.user}.extraGroups = ["media"];
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

    systemd.services = {
      # check if connected
      # sonarr.serviceConfig.ExecStartPre = pkgs.writeScript "test" ''
      #   #!/bin/sh
      #   ${pkgs.curl}/bin/curl https://am.i.mullvad.net/connected
      # '';

      # Sonarr / Radarr should not be behind vpn
      # sonarr.vpnConfinement = enableAnd {
      #   vpnNamespace = "mullvad";
      # };
      # radarr.vpnConfinement = enableAnd {
      #   vpnNamespace = "mullvad";
      # };
    };

    services = {
      prowlarr = {
        enable = true;
        apiKeyFile = config.sops.secrets."prowlarr/api-key".path;
        settings = {
          # update.mechanism = "internal";
          server = {
            # urlbase = "localhost";
            port = ports.prowlarr;
            # bindaddress = "*";
          };
        };
        guiSettings = {
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
                host = ips.mullvad;
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
        apiKeyFile = config.sops.secrets."radarr/api-key".path;
        settings = {
          # update.mechanism = "internal";
          server = {
            # urlbase = ips.mullvad;
            port = ports.radarr;
            # bindaddress = "*";
          };
        };
        guiSettings = {
          host = {
            username = "admin";
            password = config.sops.secrets."radarr/password".path;
            apiKey = config.sops.secrets."radarr/api-key".path;
          };
          rootFolders = ["/media/movies"];
          downloadClients = {
            "qBittorrent" = {
              implementation = "QBittorrent";
              fields = {
                port = ports.qbit;
                host = ips.mullvad;
                username = "admin";
                password = config.sops.secrets."qbit/password_radarr".path;
                sequentialOrder = true;
              };
            };
          };

          quality = {
            WEBRip-1080p.bitrate = {
              min = 0;
              preferred = 50; # ~2.9 GB/h
              max = 100;
            };
            WEBDL-1080p.bitrate = {
              min = 0;
              preferred = 50;
              max = 100;
            };
            HDTV-1080p.bitrate = {
              min = 0;
              preferred = 50;
              max = 100;
            };
            Bluray-1080p.bitrate = {
              min = 0;
              preferred = 50;
              max = 100;
            };
            Remux-1080p.bitrate = {
              min = 0;
              preferred = 50;
              max = 100;
            };
          };
        };
      };

      sonarr = {
        enable = true;
        group = "media";
        apiKeyFile = config.sops.secrets."sonarr/api-key".path;
        settings = {
          # update.mechanism = "internal";
          server = {
            # urlbase = ips.mullvad;
            port = ports.sonarr;
            # bindaddress = "*";
          };
        };
        guiSettings = {
          host = {
            username = "admin";
            password = config.sops.secrets."sonarr/password".path;
          };
          rootFolders = ["/media/tv"];
          downloadClients = {
            "qBittorrent" = {
              implementation = "QBittorrent";
              fields = {
                port = ports.qbit;
                host = ips.mullvad;
                username = "admin";
                password = config.sops.secrets."qbit/password_sonarr".path;
                sequentialOrder = true;
              };
            };
          };

          quality = {
            HDTV-1080p.bitrate = {
              min = 4;
              preferred = 50;
              max = 100;
            };
            WEBRip-1080p.bitrate = {
              min = 4;
              preferred = 50;
              max = 100;
            };
            WEBDL-1080p.bitrate = {
              min = 4;
              preferred = 50;
              max = 100;
            };
            Bluray-1080p.bitrate = {
              min = 4;
              preferred = 50;
              max = 100;
            };
            "Bluray-1080p Remux".bitrate = {
              min = 4;
              preferred = 50;
              max = 150;
            };
          };
        };
      };
    };
  };
}
