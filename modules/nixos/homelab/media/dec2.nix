{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types;
  # inherit (my_lib.opt) mkEnableOpt;

  curl_base = api_key_path: base_url: type: url: t: data:
  # bash
  ''
    cat "${pkgs.writeText "data.json" (builtins.toJSON data)}" \
    ${t}| curl \
        --silent \
        --show-error \
        --retry 3 \
        --retry-connrefused \
        --url "${base_url}${url}" \
        -X ${type} \
        -H "X-Api-Key: $(cat "${api_key_path}")" \
        -H "Content-Type: application/json" \
        --data-binary @-'';

  json-file-resolve =
    pkgs.writers.writePython3Bin "json-file-resolve" {
      libraries = with pkgs.python3Packages; [
        jsonpath-ng
      ];
    } ''
      import json
      import jsonpath_ng.ext as jsonpath
      import sys


      def func(_, data, field):
          file_path = data[field]

          with open(file_path) as f:
              return f.read().strip()


      json_data_raw = sys.stdin.read()
      data = json.loads(json_data_raw)
      for arg in sys.argv[1:]:
          jsonpath.parse(arg).update(data, func)

      print(json.dumps(data, indent=2))
    '';

  mkArrContract = d:
    d
    // {
      enable = true;
      configContract = "${d.implementation}Settings";
      fields =
        lib.mapAttrsToList (n: v: {
          name = n;
          value = v;
        })
        d.fields;
    };

  mkArrConfig = {
    serviceName,
    dataDir,
    appUrl,
    enableNaming ? false,
    namingDefault ? {},
    enableRootFolders ? false,
    enableMediaManagement ? false,
    enableIndexers ? false,
    enableApplications ? false,
  }: let
    cfg = config.services.${serviceName};
    s = cfg.extraSettings;

    curl' =
      curl_base
      cfg.apiKeyFile
      appUrl;
    curl = type: url: curl' type url "";

    init-script = pkgs.writeShellApplication {
      name = "${serviceName}-init";
      extraShellCheckFlags = [
        "-S"
        "error"
      ];
      runtimeInputs = with pkgs; [
        sqlite
        openssl
        unixtools.xxd
        pkgs.curl
        jq
        util-linux # uuidgen
        json-file-resolve
      ];
      text =
        # bash
        ''
          db_file="${dataDir}/${serviceName}.db"

          echo "Starting ${serviceName} to generate db..."
          ${lib.getExe cfg.package} -nobrowser -data="${cfg.dataDir}"&

          echo "Waiting for db to be created..."
          until [ -f "$db_file" ]
          do
            sleep 1
          done

          echo "Waiting for the users table to be created..."
          while true; do
            sqlite3 $db_file "
              SELECT 1 FROM sqlite_master
              WHERE type='table'
              AND name='users';
            " > /dev/null 2>&1

            if [ $? -eq 0 ]; then
              break
            fi

            sleep 1
          done

          echo "Wating for other tables to be created"
          sleep 5 # wait for other tables to exist

          # might have to put this twice, ref says that the first put doesn't
          # work
          # i suspect that is due to it not having started yet
          # This seams to not be the case

          echo "Sending api requests to configure applicaion"

          ${curl' "PUT" "/config/host/1" ''
              | json-file-resolve \
                '$.password' \
                '$.passwordConfirmation' \
                '$.apiKey' \
            '' ({
                id = 1;
                # apiKey = "rce80fr3hvn5avwsb2xogcfluzoqh73o";
                apiKey = cfg.apiKeyFile;

                analyticsEnabled = false;

                authenticationMethod = "forms";
                authenticationRequired = "enabled";

                # username = "admin";
                # password = "";
                passwordConfirmation = s.host.password;

                backupInterval = 7;
                backupRetention = 28;

                port = cfg.settings.server.port;
                urlBase = "";
                bindAddress = "*";
                proxyEnabled = false;
                sslCertPath = "";
                sslCertPassword = "";
                instanceName = serviceName;

                branch = "main";
                logLevel = "debug";
                consoleLogLevel = "";
                logSizeLimit = 1;
                updateScriptPath = "";
              }
              // s.host)}

          ${lib.optionalString enableNaming ''
            ${curl "PUT" "/config/naming/1" (
              {id = 1;}
              // namingDefault
              // s.naming
            )}
          ''}

          ${lib.optionalString enableMediaManagement ''
            ${curl "PUT" "/config/mediamanagement/1" ({
                id = 1;
                importExtraFiles = true;
                extraFileExtensions = "srt";
                deleteEmptyFolders = true;

                # GUI defaults
                copyUsingHardlinks = true;
                recycleBinCleanupDays = 7;
                minimumFreeSpaceWhenImporting = 100;
                enableMediaInfo = true;
              }
              // s.mediaManagement)}
          ''}


          delete-one () {
            ${curl "DELETE" "/$1/$2" {}} #
          }

          delete-all () {
            ids=$(${curl "GET" "/$1" {}} | jq ".[].id")

            for id in $ids; do
              delete-one "$1" "$id"
            done
          }

          ${lib.optionalString enableRootFolders
            # bash
            ''
              echo "Deleting old root folders"
              delete-all "rootfolder"

              echo "Creating root folders"
              ${lib.concatStrings (
                lib.imap1 (_: d: (curl "POST" "/rootfolder" {
                  path = d;
                }))
                s.rootFolders
              )}
            ''}

          echo "Deleting old download clients"
          delete-all "downloadclient"

          echo "Creating download clients"
          ${lib.concatStrings (
            lib.imap1 (_: d: (
              curl' "POST" "/downloadclient" ''
                | json-file-resolve \
                  '$.fields[?(@.name=="password")].value' \
              '' ({
                  categories = [];
                }
                // (mkArrContract d))
            ))
            (lib.mapAttrsToList
              (n: v: {name = n;} // v)
              s.downloadClients)
          )}

          ${lib.optionalString enableIndexers
            # bash
            ''
              echo "Deleting old indexers"
              delete-all "indexer"

              echo "Creating indexers"
              ${lib.concatStrings (
                lib.imap1 (_: d: (
                  curl' "POST" "/indexer" ''
                    | json-file-resolve \
                      '$.fields[?(@.name=="password")].value' \
                  '' ({
                      appProfileId = 1;
                      priority = 25;
                    }
                    // (mkArrContract d))
                ))
                (lib.mapAttrsToList
                  (n: v: {name = n;} // v)
                  s.indexers)
              )}
            ''}

          ${lib.optionalString enableApplications
            # bash
            ''
              echo "Deleting old applications"
              delete-all "applications"

              echo "Creating applications"
              ${lib.concatStrings (
                lib.imap1 (_: d: (
                  curl' "POST" "/applicaions" ''
                    | json-file-resolve \
                      '$.fields[?(@.name=="apiKey")].value' \
                  '' ({
                      appProfileId = 1;
                    }
                    // (mkArrContract d))
                ))
                (lib.mapAttrsToList
                  (n: v: {name = n;} // v)
                  s.applications)
              )}
            ''}

          echo "${serviceName} init finished"
          wait
        '';
    };
  in {
    options.services.${serviceName} = {
      apiKeyFile = mkOption {
        type = types.str;
      };

      extraSettings = mkOption {
        description = ''
          Each suboption is an api route, and the contens is mapped directly to
          the json body of the request. Refer to what the gui sends for what
          thease should be.

          The set value will be merged with the default value (not really but
          with the same value as the default is)

          The <name> of the attr propegates to the name field.
        '';
        type = types.submodule {
          options =
            lib.getAttrs (
              ["host" "downloadClients"]
              ++ lib.optional enableRootFolders "rootFolders"
              ++ lib.optional enableNaming "naming"
              ++ lib.optional enableMediaManagement "mediaManagement"
              ++ lib.optional enableIndexers "indexers"
              ++ lib.optional enableApplications "applications"
            ) {
              host = mkOption {
                type = types.attrs;
                description = ''
                  The initial setup request
                '';
                default = {};
              };
              applications = mkOption {
                type = types.attrs;
                description = ''

                '';
                default = {};
              };
              indexers = mkOption {
                type = types.attrs;
                description = ''

                '';
                default = {};
              };
              mediaManagement = mkOption {
                type = types.attrs;
                description = ''

                '';
                default = {};
              };
              naming = mkOption {
                type = types.attrs;
                description = ''

                '';
                default = {};
              };
              rootFolders = mkOption {
                type = types.listOf types.str;
                description = ''
                  Mapped to the correct format
                '';
                default = [];
                example = ["/srv/${serviceName}"];
              };
              downloadClients = mkOption {
                type = types.attrs;
                description = ''
                  The attr "fields" are mapped into the key value pairs that the
                  api expects.

                  The password feild should be a file, it will be replaces by the
                  files content during runtime.
                '';
                default = {};
                example = {
                  "qBittorrent" = {
                    implementation = "QBittorrent";
                    fields = {
                      port = 8080;
                      username = "admin";
                      password = "config.sops.secrets.\"qbit/passoword\"";
                    };
                  };
                };
              };
            };
        };
      };
    };

    config = {
      systemd.services.${serviceName} = {
        serviceConfig = {
          ExecStart = lib.mkForce "${lib.getExe init-script}";
        };
      };
    };
  };
in {
  imports = [
    (mkArrConfig {
      serviceName = "sonarr";
      dataDir = "${config.services.sonarr.dataDir}/.config/Sonarr";
      appUrl = "http://localhost:${toString config.services.sonarr.settings.server.port}/api/v3";

      enableNaming = true;
      namingDefault = {
        renameEpisodes = true;
        replaceIllegalCharacters = true;
        colonReplacementFormat = 0;
        customColonReplacementFormat = "";
        multiEpisodeStyle = 0;
        standardEpisodeFormat = "{Series Title} - S{season:00}E{episode:00} - {Episode Title} {Quality Title} {MediaInfo VideoCodec}";
        dailyEpisodeFormat = "{Series Title} - {Air-Date} - {Episode Title} {Quality Title} {MediaInfo VideoCodec}";
        animeEpisodeFormat = "{Series Title} - S{season:00}E{episode:00} - {Episode Title} {Quality Title} {MediaInfo VideoCodec}";
        seriesFolderFormat = "{Series Title}";
        seasonFolderFormat = "Season {season}";
        specialsFolderFormat = "Specials";
      };
      enableRootFolders = true;
      enableMediaManagement = true;
    })

    (mkArrConfig {
      serviceName = "radarr";
      dataDir = config.services.radarr.dataDir;
      appUrl = "http://localhost:${toString config.services.radarr.settings.server.port}/api/v3";

      namingDefault = {
        renameMovies = true;
        replaceIllegalCharacters = true;
        standardMovieFormat = "{Movie Title} ({Release Year}) {Quality Title} {MediaInfo VideoCodec}";
        movieFolderFormat = "{Movie Title} ({Release Year})";
      };
      enableRootFolders = true;
      enableMediaManagement = true;
    })

    (mkArrConfig {
      serviceName = "prowlarr";
      dataDir = config.services.prowlarr.dataDir;
      appUrl = "http://localhost:${toString config.services.prowlarr.settings.server.port}/api/v1";

      enableIndexers = true;
      enableApplications = true;
    })
  ];
}
