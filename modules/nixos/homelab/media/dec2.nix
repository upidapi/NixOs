{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types;
  # inherit (my_lib.opt) mkEnableOpt;
  # cfg = config.modules.nixos.homelab.media.dec;
in {
  # options.modules.nixos.homelab.media.dec = mkEnableOpt "";
  options.services.sonarr = {
    # passwordFile = mkOption {
    #   type = types.str;
    # };
    # username = mkOption {
    #   type = types.str;
    # };
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
      '';
      type = types.submodule {
        options = {
          host = mkOption {
            type = types.attrs;
            description = ''
              The initial setup request
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
            example = ["/srv/sonarr"];
          };
          downloadClients = mkOption {
            type = types.attrs;
            description = ''
              The attr "name" propergates to the name feild.

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
                  password = "config.sops.secrets.\"qbit/passoword_sonarr\"";
                };
              };
            };
          };
        };
      };
    };
  };

  config = let
    # --dump-header - \
    curl_base = api_key_path: base_url: type: url: t: data: ''
      cat "${pkgs.writeText "data.json" (builtins.toJSON data)}" \
      ${t}| curl \
          --silent \
          --show-error \
          --retry 3 \
          --retry-connrefused \
          --url ${base_url}${url} \
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

    sonarr-init = let
      sonarrPort = config.services.sonarr.settings.server.port;
      curl' =
        curl_base
        # "$CREDENTIALS_DIRECTORY/api-key"
        cfg.apiKeyFile
        "http://localhost:${toString sonarrPort}/api/v3";
      curl = type: url: curl' type url "";
      cfg = config.services.sonarr;
      s = cfg.extraSettings;
    in
      pkgs.writeShellApplication {
        name = "sonarr-init";
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
            db_file="${cfg.dataDir}/.config/Sonarr/sonarr.db"

            echo "Starting sonarr to generate db..."
            ${lib.getExe cfg.package} &

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

            ${curl' "PUT" "/config/host/1" ''
                | json-file-resolve \
                  '$.password' \
                  '$.passwordConfirmation' \
                  '$.apiKey' \
              '' ({
                  id = 1;
                  # apiKey = "rce80fr3hvn5avwsb2xogcfluzoqh73o";

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
                  instanceName = "Sonarr";

                  branch = "main";
                  logLevel = "debug";
                  consoleLogLevel = "";
                  logSizeLimit = 1;
                  updateScriptPath = "";
                }
                // s.host)}

            ${curl "PUT" "/config/naming/1" ({
                id = 1;
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
              }
              // s.naming)}

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


            delete-one () {
              ${curl "DELETE" "/$1/$2" {}} #
            }

            delete-all () {
              ids=$(${curl "GET" "/$1" {}} | jq ".[].id")
              for id in $ids; do
                delete-one $1
              done
            }

            echo "Deleting old root folders"
            delete-all "rootfolder"

            echo "Creating root folders"
            ${lib.concatStrings (
              lib.imap1 (_: d: (curl "POST" "/rootfolder" {
                path = d;
              }))
              s.rootFolders
            )}

            echo "Deleting old download clients"
            delete-all "downloadclient"

            echo "Creating download clients"
            ${lib.concatStrings (
              lib.imap1 (_: d: (
                curl' "POST" "/downloadclient" ''
                  | json-file-resolve \
                    '$.fields[?(@.name=="password")].value' \
                '' ({
                    enable = true;
                    categories = [];

                    configContract = "${d.implementation}Settings";
                    fields =
                      lib.mapAttrsToList (n: v: {
                        name = n;
                        value = v;
                      })
                      d.fields;
                  }
                  // (lib.removeAttrs d ["fields"]))
              ))
              (lib.mapAttrsToList
                (n: v: {name = n;} // v)
                s.downloadClients)
            )}

            echo "Sent all requests, wating for them to finish"
            wait
          '';
      };
  in {
    systemd.services.sonarr = {
      serviceConfig = {
        # WorkingDirectory = cfg.dataDir;
        # ExecStartPre = "${jellyseerr-init}";
        ExecStart = lib.mkForce "${lib.getExe sonarr-init}";
        # ExecStartPost = "${jellyseerr-setup}";
        # ExecStartPost = "/srv/test.sh";
        # LoadCredential = [
        #   "api-key:${config.services.sonarr.apiKeyFile}"
        #   "psq:${config.services.sonarr.passwordFile}"
        # ];
      };
    };
  };
}
/*
{
  "enable": true,
  "protocol": "torrent",
  "priority": 1,
  "removeCompletedDownloads": true,
  "removeFailedDownloads": true,
  "name": "qBittorrent",
  "fields": [
    { "name": "host", "value": "localhost" },
    { "name": "port", "value": 8080 },
    { "name": "useSsl", "value": false },
    { "name": "urlBase" },
    { "name": "username", "value": "admin" },
    { "name": "password", "value": "YwMxtLeVrIy4z4xXRdObe9XpXH9Qnm1C" },
    { "name": "tvCategory", "value": "tv-sonarr" },
    { "name": "tvImportedCategory" },
    { "name": "recentTvPriority", "value": 0 },
    { "name": "olderTvPriority", "value": 0 },
    { "name": "initialState", "value": 0 },
    { "name": "sequentialOrder", "value": true },
    { "name": "firstAndLast", "value": false },
    { "name": "contentLayout", "value": 0 }
  ],
  "implementationName": "qBittorrent",
  "implementation": "QBittorrent",
  "configContract": "QBittorrentSettings",
  "infoLink": "https://wiki.servarr.com/sonarr/supported#qbittorrent",
  "tags": []
}

downloadClients = {
  "qBittorrent" = {
    implementation = "QBittorrent";
    fields = {
      port = qBittorrent.Preferences."WebUI\\Port";
    };
  };
};
*/

