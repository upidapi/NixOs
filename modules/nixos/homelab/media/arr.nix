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
  inherit (lib) mkIf mkOption;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.homelab.media.arr;

  mkArrSerivice = name: let
    apiKeyEnvVar = "${lib.toUpper name}__AUTH__APIKEY";
    cfg = config.services.${name};
  in {
    options.services.${name}.apiKeyFile = mkOption {
      type = lib.types.str;
    };
    config.systemd.services.${name}.serviceConfig.ExecStart = mkIf cfg.enable (
      lib.mkForce
      (pkgs.writeShellScript
        "init-${name}" ''
          ${apiKeyEnvVar}=$(cat ${cfg.apiKeyFile}) \
            ${lib.getExe cfg.package} \
            -nobrowser \
            -data="${cfg.dataDir}"
        '')
    );
  };
in {
  options.modules.nixos.homelab.media.arr = mkEnableOpt "";

  # REF: buildarr referance
  #  https://github.com/elliott-farrall/dotfiles/blob/c4699d8c61fbbb23d6cb8b244be054c0f39848a5/systems/x86_64-linux/broad/services/media/buildarr/config.yaml

  imports = [
    # inputs.declarative-arr.nixosModules.default
    inputs.declarr.nixosModules.default
    (mkArrSerivice "sonarr")
    (mkArrSerivice "radarr")
    (mkArrSerivice "prowlarr")
  ];

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings = {
      "media-dir-create" = {
        "/raid/media/movies".d = {
          group = "media";
          user = "radarr";
          mode = "751";
        };
        "/raid/media/movies".Z = {
          group = "media";
          user = "radarr";
          mode = "751";
        };
        # "/raid/media/subtitles".d = {
        #   group = "media";
        #   user = "bazarr";
        #   mode = "751";
        # };
        "/raid/media/tv".d = {
          group = "media";
          user = "sonarr";
          mode = "751";
        };
        "/raid/media/tv".Z = {
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
        url = "http://${ips.mullvad}:${toString ports.qbit}";
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

      sonarr.after = ["qbittorrent.service"];
      radarr.after = ["qbittorrent.service"];
      prowlarr.after = ["qbittorrent.service" "sonarr.service" "prowlarr.service"];
    };

    services = {
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
      };
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
      };
      declarr = {
        enable = true;

        config = rec {
          declarr = {
            globalResolvePaths = [
              "$.*.config.host.password"
              "$.*.config.host.passwordConfirmation"
              "$.*.config.host.apiKey"
              "$.*.applications.*.fields.apiKey"
              "$.*.indexer.*.fields.password"
              "$.*.downloadClient.*.fields.password"
            ];
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
                  host = ips.mullvad;
                  username = "admin";
                  password = config.sops.secrets."qbit/password_declarr".path;
                  sequentialOrder = true;
                };
              };
            };
            qualityDefinition = {
              HDTV-1080p = {
                minSize = 4;
                preferredSize = 50;
                maxSize = 100;
              };
              WEBRip-1080p = {
                minSize = 4;
                preferredSize = 50;
                maxSize = 100;
              };
              WEBDL-1080p = {
                minSize = 4;
                preferredSize = 50;
                maxSize = 100;
              };
              Bluray-1080p = {
                minSize = 4;
                preferredSize = 50;
                maxSize = 100;
              };
              "Bluray-1080p Remux" = {
                minSize = 4;
                preferredSize = 50;
                maxSize = 150;
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
            downloadClient = {
              "qBittorrent" = {
                implementation = "QBittorrent";
                fields = {
                  port = ports.qbit;
                  host = ips.mullvad;
                  username = "admin";
                  password = config.sops.secrets."qbit/password_declarr".path;
                  sequentialOrder = true;
                };
              };
            };

            qualityDefinition = {
              WEBRip-1080p = {
                minSize = 0;
                preferredSize = 50; # ~2.9 GB/h
                maxSize = 100;
              };
              WEBDL-1080p = {
                minSize = 0;
                preferredSize = 50;
                maxSize = 100;
              };
              HDTV-1080p = {
                minSize = 0;
                preferredSize = 50;
                maxSize = 100;
              };
              Bluray-1080p = {
                minSize = 0;
                preferredSize = 50;
                maxSize = 100;
              };
              Remux-1080p = {
                minSize = 0;
                preferredSize = 50;
                maxSize = 100;
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
                fields.apiKey = config.sops.secrets."sonarr/api-key_declarr".path;
              };
              "Radarr" = {
                syncLevel = "fullSync";
                implementation = "Radarr";
                fields.apiKey = config.sops.secrets."radarr/api-key_declarr".path;
              };
            };

            downloadClient = {
              "qBittorrent" = {
                implementation = "QBittorrent";
                fields = {
                  port = ports.qbit;
                  host = ips.mullvad;
                  username = "admin";
                  password = config.sops.secrets."qbit/password_declarr".path;
                  sequentialOrder = true;
                };
              };
            };
            indexerProxy = {
              "FlareSolverr" = {
                fields = {
                  host = "http://localhost:8191/";
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

              "1337x" = {
                implementation = "Cardigann";
                priority = 25; # default 25
                fields = {
                  definitionFile = "1337x";
                  downloadlink = 1; # magnet
                  downloadlink2 = 0; # iTorrents.org
                  sort = 2; # created
                  type = 1; # desc
                };
                tags = ["FlareSolverr"];
                appProfileId = "Standard";
              };
              "LimeTorrents" = {
                implementation = "Cardigann";
                priority = 30; # default 25
                fields = {
                  definitionFile = "limetorrents";
                  downloadlink = 1; # magnet
                  downloadlink2 = 0; # iTorrents.org
                };
              };
              "The Pirate Bay" = {
                implementation = "Cardigann";
                priority = 30; # default 25
                fields = {
                  definitionFile = "thepiratebay";
                };
              };
              "YTS" = {
                implementation = "Cardigann";
                priority = 30; # default 25
                fields = {
                  definitionFile = "yts";
                };
              };
            };
          };
        };
      };
    };
  };
}
