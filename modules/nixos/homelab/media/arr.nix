{
  config,
  lib,
  mlib,
  const,
  self,
  inputs,
  pkgs,
  ...
}: let
  inherit (const) ports ips;
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.homelab.media.arr;
in {
  options.modules.nixos.homelab.media.arr = mkEnableOpt "";

  # REF: buildarr referance
  #  https://github.com/elliott-farrall/dotfiles/blob/c4699d8c61fbbb23d6cb8b244be054c0f39848a5/systems/x86_64-linux/broad/services/media/buildarr/config.yaml

  imports = [
    # inputs.declarative-arr.nixosModules.default
    inputs.declarr.nixosModules.default
  ];

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings = {
      "media-dir-create" = {
        "/raid/media/movies".d = {
          group = "radarr";
          user = "radarr";
          mode = "751";
        };
        "/raid/media/movies".Z = {
          group = "radarr";
          user = "radarr";
          mode = "751";
        };
        # "/raid/media/subtitles".d = {
        #   group = "media";
        #   user = "bazarr";
        #   mode = "751";
        # };
        "/raid/media/tv".d = {
          group = "sonarr";
          user = "sonarr";
          mode = "751";
        };
        "/raid/media/tv".Z = {
          group = "sonarr";
          user = "sonarr";
          mode = "751";
        };

        "/raid/media/music".d = {
          group = "lidarr";
          user = "lidarr";
          mode = "751";
        };
        "/raid/media/music".Z = {
          group = "lidarr";
          user = "lidarr";
          mode = "751";
        };
      };
    };

    users.users = {
      ${config.services.radarr.user}.extraGroups = ["qbittorrent"];
      ${config.services.sonarr.user}.extraGroups = ["qbittorrent"];
      ${config.services.lidarr.user}.extraGroups = ["qbittorrent"];
      ${config.services.bazarr.user}.extraGroups = ["qbittorrent"];

      ${config.services.jellyfin.user}.extraGroups = ["sonarr" "radarr" "lidarr"];
      ${config.services.jellyseerr.user}.extraGroups = [];
    };

    sops.secrets = {
      "qbit/password_declarr" = {
        key = "qbit/password";
        owner = config.services.declarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };

      "radarr/api-key" = {
        owner = config.services.radarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
      "radarr/api-key_declarr" = {
        key = "radarr/api-key";
        owner = config.services.declarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
      "radarr/password_declarr" = {
        key = "radarr/password";
        owner = config.services.declarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };

      "lidarr/api-key" = {
        owner = config.services.lidarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
      "lidarr/api-key_declarr" = {
        key = "lidarr/api-key";
        owner = config.services.declarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
      "lidarr/password_declarr" = {
        key = "lidarr/password";
        owner = config.services.declarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };

      "sonarr/api-key" = {
        owner = config.services.sonarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
      "sonarr/api-key_declarr" = {
        key = "sonarr/api-key";
        owner = config.services.declarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
      "sonarr/password_declarr" = {
        key = "sonarr/password";
        owner = config.services.declarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };

      "prowlarr/api-key" = {
        owner = config.services.prowlarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
      "prowlarr/api-key_declarr" = {
        key = "prowlarr/api-key";
        owner = config.services.declarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
      "prowlarr/password_declarr" = {
        key = "prowlarr/password";
        owner = config.services.declarr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };

      "prowlarr/indexers/torrentLeech/password_declarr" = {
        key = "prowlarr/indexers/torrentLeech/password";
        owner = config.services.declarr.user;
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

      declarr.serviceConfig.ExecStartPre = let
        pswFile = config.sops.secrets."qbit/password_declarr".path;
        url = "http://${ips.proton}:${toString ports.qbit}";
      in
        pkgs.writeShellScript
        "declarr_wait-for-deps" ''
          echo "Wating for qbittorrent to start"
          ${pkgs.curl}/bin/curl "${url}/api/v2/auth/login" \
            --retry-connrefused \
            --retry 5 --retry-delay 5 \
            --data-urlencode "username=admin" \
            --data-urlencode "password=$(cat ${pswFile})"
        '';

      sonarr = {
        after = ["qbittorrent.service"];
        serviceConfig.ReadOnlyPaths = ["/raid/media/torrents"];
      };
      radarr = {
        after = ["qbittorrent.service"];
        serviceConfig.ReadOnlyPaths = ["/raid/media/torrents"];
      };
      lidarr = {
        after = ["qbittorrent.service"];
        serviceConfig.ReadOnlyPaths = ["/raid/media/torrents"];
      };

      prowlarr.after = ["qbittorrent.service" "lidarr.service" "sonarr.service" "radarr.service"];
    };

    # TODO: IDEA: have a group on services with dynamic user, make that group
    #  own the secrets, so that they can be accessed

    services = {
      sonarr = {
        enable = true;
        # group = "media";
        apiKeyFile = config.sops.secrets."sonarr/api-key".path;
        settings.server.port = ports.sonarr;
      };
      radarr = {
        enable = true;
        # group = "media";
        apiKeyFile = config.sops.secrets."radarr/api-key".path;
        settings.server.port = ports.radarr;
      };
      lidarr = {
        enable = true;
        # group = "media";
        apiKeyFile = config.sops.secrets."lidarr/api-key".path;
        settings.server.port = ports.lidarr;
      };
      prowlarr = {
        enable = true;
        apiKeyFile = config.sops.secrets."prowlarr/api-key".path;
        settings.server.port = ports.prowlarr;
      };
      declarr = {
        enable = true;

        config = rec {
          declarr = {
            stateDir = "/var/lib/declarr";

            globalResolvePaths = [
              "$.*.config.host.password"
              "$.*.config.host.passwordConfirmation"
              "$.*.config.host.apiKey"
              "$.*.applications.*.fields.apiKey"
              "$.*.indexer.*.fields.password"
              "$.*.downloadClient.*.fields.password"
            ];

            formatDbRepo = "https://github.com/Dictionarry-Hub/Database";
            formatDbBranch = "stable";
          };

          sonarr = {
            declarr = {
              type = "sonarr";
              url = "http://localhost:${toString ports.sonarr}";
            };
            rootFolder = ["/raid/media/tv"];
            downloadClient = {
              "qBittorrent" = {
                implementation = "QBittorrent";
                fields = {
                  port = ports.qbit;
                  host = ips.proton;
                  username = "admin";
                  password = config.sops.secrets."qbit/password_declarr".path;
                  sequentialOrder = true;
                };
              };
            };
            customFormat = {};
            qualityProfile = {
              "1080p Balanced" = {};
              "1080p Quality" = {};
              "2160p Balanced" = {};
              "2160p Quality" = {};
            };
            # FROM: https://trash-guides.info/Sonarr/Sonarr-Quality-Settings-File-Size/#standard
            # 1000 is inf
            qualityDefinition = {
              HDTV-720p = {
                minSize = 10;
                preferredSize = 995;
                maxSize = 1000;
              };
              HDTV-1080p = {
                minSize = 15;
                preferredSize = 995;
                maxSize = 1000;
              };
              WEBRip-720p = {
                minSize = 10;
                preferredSize = 995;
                maxSize = 1000;
              };
              WEBDL-720p = {
                minSize = 10;
                preferredSize = 995;
                maxSize = 1000;
              };
              Bluray-720p = {
                minSize = 17.1;
                preferredSize = 995;
                maxSize = 1000;
              };
              WEBRip-1080p = {
                minSize = 15;
                preferredSize = 995;
                maxSize = 1000;
              };
              WEBDL-1080p = {
                minSize = 15;
                preferredSize = 995;
                maxSize = 1000;
              };
              Bluray-1080p = {
                minSize = 50.4;
                preferredSize = 995;
                maxSize = 1000;
              };
              "Bluray-1080p Remux" = {
                minSize = 69.1;
                preferredSize = 995;
                maxSize = 1000;
              };
              HDTV-2160p = {
                minSize = 25;
                preferredSize = 995;
                maxSize = 1000;
              };
              WEBRip-2160p = {
                minSize = 25;
                preferredSize = 995;
                maxSize = 1000;
              };
              WEBDL-2160p = {
                minSize = 25;
                preferredSize = 995;
                maxSize = 1000;
              };
              Bluray-2160p = {
                minSize = 94.6;
                preferredSize = 995;
                maxSize = 1000;
              };
              "Bluray-2160p Remux" = {
                minSize = 187.4;
                preferredSize = 995;
                maxSize = 1000;
              };
            };
            notification = {
              discord = {
                implementation = "Discord";
                fields = {
                  # webHookUrl = config.sops.secrets."sonarr/discord-webhook_declarr".path;
                  webHookUrl = "https://discord.com/api/webhooks/1453131389921919228/QdTSKjeeo6TlVlwxgRziL8ZkOd6OcIRtaeqCjGjn_dZ3VOMeXYjYZglNrt_6mwNNyk6V";
                };
              };
            };
            config = {
              ui = {
                firstDayOfWeek = 1; # 0 = Sunday, 1 = Monday
                timeFormat = "HH:mm"; # HH:mm = 17:30, h(:mm)a = 5:30PM
                theme = "dark";
              };
              host = rec {
                # id = 1;
                apiKey = config.sops.secrets."sonarr/api-key_declarr".path;

                analyticsEnabled = false;

                authenticationMethod = "forms";
                authenticationRequired = "enabled";

                # username = "admin";
                # password = "";

                username = "admin";
                password = config.sops.secrets."sonarr/password_declarr".path;
                passwordConfirmation = password;

                backupInterval = 7;
                backupRetention = 28;

                port = ports.sonarr;
                urlBase = "";
                bindAddress = "*";
                proxyEnabled = false;
                sslCertPath = "";
                sslCertPassword = "";
                instanceName = "Sonarr";
                # if instanceName == null
                # then serviceName
                # else instanceName;

                branch = "main";
                logLevel = "debug";
                consoleLogLevel = "";
                logSizeLimit = 1;
                updateScriptPath = "";
              };
              naming = {
                renameEpisodes = true;
                replaceIllegalCharacters = true;
                colonReplacementFormat = 4;
                customColonReplacementFormat = "";
                multiEpisodeStyle = 5;
                standardEpisodeFormat = "s{season:00}e{episode:00} - {Episode Title} {Quality Title} {MediaInfo VideoCodec}";
                dailyEpisodeFormat = "{Air-Date} - {Episode Title} {Quality Title} {MediaInfo VideoCodec}";
                animeEpisodeFormat = "s{season:00}e{episode:00} - {Episode Title} {Quality Title} {MediaInfo VideoCodec}";
                seriesFolderFormat = "{Series Title}";
                seasonFolderFormat = "Season {season}";
                specialsFolderFormat = "Specials";
              };
              mediamanagement = {
                autoUnmonitorPreviouslyDownloadedEpisodes = false;

                setPermissionsLinux = false;
                chmodFolder = "755";
                chownGroup = "";

                # createEmptySeriesFolders = false;
                createEmptySeriesFolders = true;
                deleteEmptyFolders = false;

                enableMediaInfo = true;
                episodeTitleRequired = "always";
                extraFileExtensions = "srt";
                fileDate = "none";

                recycleBin = "";
                recycleBinCleanupDays = 7;

                rescanAfterRefresh = "always";

                downloadPropersAndRepacks = "preferAndUpgrade";

                copyUsingHardlinks = true;
                minimumFreeSpaceWhenImporting = 100;
                skipFreeSpaceCheckWhenImporting = false;
                importExtraFiles = false;
                useScriptImport = false;
                scriptImportPath = "";
              };
            };
          };

          lidarr = {
            declarr = {
              type = "lidarr";
              url = "http://localhost:${toString ports.lidarr}";
            };

            config = {
              inherit (sonarr.config) mediamanagement ui;
              host =
                sonarr.config.host
                // rec {
                  instanceName = "Lidarr";
                  username = "admin";
                  password = config.sops.secrets."lidarr/password_declarr".path;
                  passwordConfirmation = password;
                  apiKey = config.sops.secrets."lidarr/api-key_declarr".path;
                  port = ports.lidarr;
                };

              naming = {
                renameTracks = false;
                replaceIllegalCharacters = true;
                colonReplacementFormat = 4;
                standardTrackFormat = "{Album Title} ({Release Year})/{Artist Name} - {Album Title} - {track:00} - {Track Title}";
                multiDiscTrackFormat = "{Album Title} ({Release Year})/{Medium Format} {medium:00}/{Artist Name} - {Album Title} - {track:00} - {Track Title}";
                artistFolderFormat = "{Artist Name}";
                includeArtistName = false;
                includeAlbumTitle = false;
                includeQuality = false;
                replaceSpaces = false;
              };
            };

            rootFolder.main = {
              path = "/raid/media/music";
              defaultQualityProfileId = "Standard";
              defaultMetadataProfileId = "Standard";
              defaultMonitorOption = "all";
              defaultNewItemMonitorOption = "all";
              defaultTags = [];
            };

            inherit (sonarr) downloadClient;

            # unlimited
            # qualityDefinition.maxSize = null
          };

          radarr = {
            declarr = {
              type = "radarr";
              url = "http://localhost:${toString ports.radarr}";
            };

            config = {
              inherit (sonarr.config) mediamanagement ui;
              host =
                sonarr.config.host
                // rec {
                  instanceName = "Radarr";
                  username = "admin";
                  password = config.sops.secrets."radarr/password_declarr".path;
                  passwordConfirmation = password;
                  apiKey = config.sops.secrets."radarr/api-key_declarr".path;
                  port = ports.radarr;
                };
              naming = {
                renameMovies = true;
                replaceIllegalCharacters = true;
                standardMovieFormat = "{Movie Title} ({Release Year}) {Quality Title} {MediaInfo VideoCodec}";
                movieFolderFormat = "{Movie Title} ({Release Year})";
              };
            };

            rootFolder = ["/raid/media/movies"];

            inherit (sonarr) downloadClient;

            customFormat = {};
            qualityProfile = {
              "1080p Balanced" = {};
              "1080p Quality" = {};
              "2160p Balanced" = {};
              "2160p Quality" = {};
            };

            # FROM: https://trash-guides.info/Radarr/Radarr-Quality-Settings-File-Size/
            # 2000 is inf
            qualityDefinition = {
              HDTV-720p = {
                minSize = 17.1;
                preferredSize = 1999;
                maxSize = 2000;
              };
              WEBDL-720p = {
                minSize = 12.5;
                preferredSize = 1999;
                maxSize = 2000;
              };
              WEBRip-720p = {
                minSize = 12.5;
                preferredSize = 1999;
                maxSize = 2000;
              };
              Bluray-720p = {
                minSize = 25.7;
                preferredSize = 1999;
                maxSize = 2000;
              };
              HDTV-1080p = {
                minSize = 33.8;
                preferredSize = 1999;
                maxSize = 2000;
              };
              WEBDL-1080p = {
                minSize = 12.5;
                preferredSize = 1999;
                maxSize = 2000;
              };
              WEBRip-1080p = {
                minSize = 12.5;
                preferredSize = 1999;
                maxSize = 2000;
              };
              Bluray-1080p = {
                minSize = 50.8;
                preferredSize = 1999;
                maxSize = 2000;
              };
              Remux-1080p = {
                minSize = 102;
                preferredSize = 1999;
                maxSize = 2000;
              };
              HDTV-2160p = {
                minSize = 85;
                preferredSize = 1999;
                maxSize = 2000;
              };
              WEBDL-2160p = {
                minSize = 34.5;
                preferredSize = 1999;
                maxSize = 2000;
              };
              WEBRip-2160p = {
                minSize = 34.5;
                preferredSize = 1999;
                maxSize = 2000;
              };
              Bluray-2160p = {
                minSize = 102;
                preferredSize = 1999;
                maxSize = 2000;
              };
              Remux-2160p = {
                minSize = 187.4;
                preferredSize = 1999;
                maxSize = 2000;
              };
            };
          };

          prowlarr = {
            declarr = {
              type = "prowlarr";
              url = "http://localhost:${toString ports.prowlarr}";
            };

            config = {
              inherit (sonarr.config) ui;
              host =
                sonarr.config.host
                // rec {
                  instanceName = "Prowlarr";
                  username = "admin";
                  password = config.sops.secrets."prowlarr/password_declarr".path;
                  passwordConfirmation = password;
                  apiKey = config.sops.secrets."prowlarr/api-key_declarr".path;
                  port = ports.prowlarr;
                };
            };

            applications = {
              "Sonarr" = {
                syncLevel = "fullSync";
                implementation = "Sonarr";
                fields = {
                  prowlarrUrl = "http://localhost:${toString ports.prowlarr}";
                  baseUrl = "http://localhost:${toString ports.sonarr}";
                  apiKey = config.sops.secrets."sonarr/api-key_declarr".path;
                };
              };
              "Radarr" = {
                syncLevel = "fullSync";
                implementation = "Radarr";
                fields = {
                  prowlarrUrl = "http://localhost:${toString ports.prowlarr}";
                  baseUrl = "http://localhost:${toString ports.radarr}";
                  apiKey = config.sops.secrets."radarr/api-key_declarr".path;
                };
              };
              "Lidarr" = {
                syncLevel = "fullSync";
                implementation = "Lidarr";
                fields = {
                  prowlarrUrl = "http://localhost:${toString ports.prowlarr}";
                  baseUrl = "http://localhost:${toString ports.lidarr}";
                  apiKey = config.sops.secrets."lidarr/api-key_declarr".path;
                };
              };
            };

            inherit (sonarr) downloadClient;

            indexerProxy = {
              "FlareSolverr" = {
                implementation = "FlareSolverr";
                fields = {
                  host = "http://localhost:${toString ports.flaresolverr}/";
                  requestTimeout = 60;
                };
                tags = ["FlareSolverr"];
              };
            };
            appProfile = {
              Standard = {
                enableAutomaticSearch = true;
                enableInteractiveSearch = true;
                enableRss = true;
                minimumSeeders = 1;
              };
              Automatic = {
                enableAutomaticSearch = true;
                enableInteractiveSearch = false;
                enableRss = true;
                minimumSeeders = 1;
              };
              "Interactive Search" = {
                enableAutomaticSearch = false;
                enableInteractiveSearch = true;
                enableRss = false;
                minimumSeeders = 1;
              };
            };
            indexer = {
              "TorrentLeech freeleech" = {
                indexerName = "TorrentLeech";
                implementation = "Cardigann";
                priority = 20; # default 25
                fields = {
                  definitionFile = "torrentleech";

                  freeleech = true;

                  username = "upidapi";
                  password = config.sops.secrets."prowlarr/indexers/torrentLeech/password_declarr".path;
                };
                tags = ["FlareSolverr"];
                appProfileId = "Automatic";
              };

              "TorrentLeech" = {
                indexerName = "TorrentLeech";
                implementation = "Cardigann";
                priority = 25; # default 25
                fields = {
                  definitionFile = "torrentleech";

                  freeleech = false;

                  username = "upidapi";
                  password = config.sops.secrets."prowlarr/indexers/torrentLeech/password_declarr".path;
                };
                tags = ["FlareSolverr"];
                appProfileId = "Interactive Search";
              };

              # "1337x" = {
              #   indexerName = "1337x";
              #   implementation = "Cardigann";
              #   priority = 25; # default 25
              #   fields = {
              #     definitionFile = "1337x";
              #     downloadlink = 1; # magnet
              #     downloadlink2 = 0; # iTorrents.org
              #     sort = 2; # created
              #     type = 1; # desc
              #   };
              #   tags = ["FlareSolverr"];
              #   appProfileId = "Standard";
              # };
              "LimeTorrents" = {
                indexerName = "LimeTorrents";
                implementation = "Cardigann";
                priority = 30; # default 25
                fields = {
                  definitionFile = "limetorrents";
                  downloadlink = 1; # magnet
                  downloadlink2 = 0; # iTorrents.org

                  # added after i got 200 ratio on a torrent
                  "torrentBaseSettings.seedRatio" = 10;
                };
                appProfileId = "Interactive Search";
              };
              "The Pirate Bay" = {
                indexerName = "The Pirate Bay";
                implementation = "Cardigann";
                priority = 30; # default 25
                fields = {
                  definitionFile = "thepiratebay";

                  "torrentBaseSettings.seedRatio" = 10;
                };
                appProfileId = "Interactive Search";
              };
              "YTS" = {
                indexerName = "YTS";
                implementation = "Cardigann";
                priority = 30; # default 25
                fields = {
                  definitionFile = "yts";

                  "torrentBaseSettings.seedRatio" = 10;
                };
                appProfileId = "Interactive Search";
              };
            };
          };
        };
      };
    };
  };
}
