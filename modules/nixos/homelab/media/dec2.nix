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
    passwordFile = mkOption {
      type = types.str;
    };
    username = mkOption {
      type = types.str;
    };
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
    # So this might be a tad overkill but idk what to do otherwise
    transform_func = ''
      transform-json () {
        settings=$(cat)

        readarray -t files < <(
          echo "$settings" | jq -r '
            [ (.fields[].value.file) | .. | scalars ] | unique | .[]
          '
        )

        jq_args=()
        for file in "''${files[@]}"; do
          if [[ ! -r "$file" ]]; then
            echo "Failed find the file \"$file\""
            exit 1
          fi

          jq_args+=(--arg "$file" "$(cat "$file")")
        done

        lookup_json=$(jq -n '$ARGS.named' "''${jq_args[@]}")

        echo "$settings" | jq --argjson lookup "$lookup_json" '
          .fields |= map(.value.file |= $lookup[.])
        '
      }
    '';
    curl_base = api_key_path: base_url: type: url: t: data: ''
      cat "${pkgs.writeText "data.json" (builtins.toJSON data)}" \
      ${t}| curl \
          --silent \
          --show-error \
          --parallel \
          --retry 3 \
          --retry-connrefused \
          --url ${base_url}${url} \
          -X ${type} \
          -H "X-Api-Key: $(cat "${api_key_path}")" \
          -H "Content-Type: application/json" \
          --data-binary @- &
    '';

    sonarr-init = let
      sonarrPort = config.services.sonarr.settings.server.port;
      curl' =
        curl_base
        "$CREDENTIALS_DIRECTORY/api-key"
        "http://localhost:${toString sonarrPort}/api/v3";
      curl = type: url: curl' type "" url;
      cfg = config.services.sonarr;
      s = cfg.extraSettings;
    in
      pkgs.writeShellScript "sonarr-init" ''
        db_file="${cfg.dataDir}/sonarr.db"

        echo "Starting sonarr to generate db..."
        ${lib.getExe cfg.package} &

        echo "Waiting for db to be created..."
        until [ -f "$db_file" ]
        do
          sleep 1
        done

        echo "Waiting for the users table to be created..."
        while true; do
          ${pkgs.sqlite}/bin/sqlite3 $db_file "
            SELECT 1 FROM sqlite_master
            WHERE type='table'
            AND name='users';
          " > /dev/null 2>&1

          if [ $? -eq 0 ]; then
            break
          fi

          sleep 1
        done

        ITERATIONS=10000
        SALT_BYTES=16
        KEY_LEN_BYTES=32
        DIGEST_ALGO="SHA512"

        PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/psw")

        SALT_HEX=$(
          openssl rand "$SALT_BYTES" \
          | xxd -p -c 256 \
          | tr -d '\n'
        )

        SALT_B64=$(
          echo -n "$SALT_HEX" \
          | xxd -r -p \
          | base64 \
          | tr -d '\n'
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
        | tr -d '\n')

        user_id=$(${pkgs.util-linux}/bin/uuidgen -N asd -n @oid --sha1)

        ${pkgs.sqlite}/bin/sqlite3 $db_file "
          DELETE FROM users;
          INSERT INTO users (
            Identifier,
            Username,
            Password,
            Salt,
            Iterations
          ) VALUES (
            '$user_id',
            '$user',
            '$DERIVED_KEY_B64',
            '$SALT_B64',
            $ITERATIONS
          );
        "

        ${transform_func} #

        # might have to put this twice, ref says that the first put doesn't
        # work
        # i suspect that is due to it not having started yet
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

        # Setup root folders
        ${lib.concatStrings (
          lib.imap1 (i: d: (curl "PUT" "/rootfolder/${toString i}" {
            path = d;
          }))
          s.rootFolders
        )}

        # Setup download clients
        ${lib.concatStrings (
          lib.imap1 (i: d: (
            curl' "PUT" "/downloadclient/${toString i}" ''
              | transform-json \
                '.fields[] | select(.name == "password") | .value' \
                '.fields |= map(
                  if .name == "password"
                    then .value = $lookup[.]
                    else .
                  end)
                ' \
            '' ({
                enable = true;
                categories = [];

                configContract = "${d.implementation}Settings";
                fields = lib.map (n: {
                  name = n;
                  value = d.fields.${n};
                });
              }
              // (lib.removeAttrs d ["feilds"]))
          ))
          (lib.mapAttrsToList
            (n: v: {name = n;} // v)
            s.downloadClients)
        )}

        echo "Sent all requests, wating for them to finish"
        wait
      '';
  in {
    systemd.services.sonarr = {
      serviceConfig = {
        # WorkingDirectory = cfg.dataDir;
        # ExecStartPre = "${jellyseerr-init}";
        ExecStart = lib.mkForce "${sonarr-init}";
        # ExecStartPost = "${jellyseerr-setup}";
        # ExecStartPost = "/srv/test.sh";
        LoadCredential = [
        ];
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

