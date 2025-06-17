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
    extraSettings = {
      mediaManagement = mkOption {
        type = types.attrs;
        description = ''
          This is mapped directly into a api request so check out what the
          web gui sends when you edit the settings.
        '';
        default = {};
      };
      naming = mkOption {
        type = types.attrs;
        description = ''
          This is mapped directly into a api request so check out what the
          web gui sends when you edit the settings.
        '';
        default = {};
      };
      rootFolders = mkOption {
        type = types.listOf types.str;
        description = ''

        '';
        default = [];
      };
      downloadClients = mkOption {
        type = types.listOf types.attrs;
        description = ''

        '';
        default = [];
      };
    };
  };

  config = let
    curl_base = api_key_path: base_url: type: url: data:
      pkgs.writeText "curl" ''
        curl \
          --silent \
          --show-error \
          --parallel \
          --retry 3 \
          --retry-connrefused \
          --url ${base_url}${url} \
          -X ${type} \
          -H "X-Api-Key: $(cat "${api_key_path}"")" \
          -H "Content-Type: application/json" \
          -d "@${pkgs.writeText "data.json" (builtins.toJSON data)}" &

      '';

    sonarr-init = let
      sonarrPort = config.services.sonarr.settings.server.port;
      curl =
        curl_base
        "$CREDENTIALS_DIRECTORY/api-key"
        "http://localhost:${toString sonarrPort}/api/v3";
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
        SALT_SIZE=16
        KEY_LEN=32

        psw=$(cat "$CREDENTIALS_DIRECTORY/psw")

        salt=$(head -c "$SALT_SIZE" /dev/urandom)
        salt_b64=$(echo -n "$salt" | ${pkgs.openssl}/bin/openssl base64)

        hash=$(${pkgs.openssl}/bin/openssl kdf \
          -kdfopt "pass:$psw" \
          -kdfopt "digest:SHA512" \
          -kdfopt "salt:$salt_b64" \
          -kdfopt "iter:$ITERATIONS" \
          -keylen "$KEY_LEN" \
          -binary \
          PBKDF2 \
        | ${pkgs.openssl}/bin/openssl base64)

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
            '$hash',
            '$salt_b64',
            $ITERATIONS
          );
        "

        # might have to put this twice, ref says that the first put doesn't
        # work
        # i suspect that is due to it not having started yet
        ${curl "PUT" "/config/naming/1" {
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
          // s.naming}

        ${curl "PUT" "/config/mediamanagement/1" {
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
          // s.mediaManagement}

        ${lib.concatStrings (
          lib.imap1 (i: d: (curl "PUT" "/rootfolder/${i}}" {
            path = d;
          }))
          s.rootFolders
        )}

        # Setup root folders
        ${lib.concatStrings (
          lib.imap1 (i: d: (curl "PUT" "/downloadclient/${i}}" {
              id = i;
              # TODO: defaults
            }
            // d))
          s.downloadClients
        )}

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
