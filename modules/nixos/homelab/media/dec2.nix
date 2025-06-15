{
  config,
  lib,
  my_lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;
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
  };

  config = let
    postStart = ''
      ${
        makeCurlScript "sonarr-curl-script"
        ''
          silent
          show-error
          parallel
        ''
        ''
          header = "X-Api-Key: ${sonarr.apiKey}"
          header = "Content-Type: application/json"
          retry = 3
          retry-connrefused
        ''
        (
          let
            naming = ''
              fail-with-body
              url = "http://localhost:${sonarr.port}/api/v3/config/naming/1"
              request = "PUT"
              data = "@${
                jsonFormat.generate "naming.json" {
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
              }"
            '';
          in
            [
              # PUT naming twice - first PUT doesn't work???
              naming
              naming
              ''
                fail-with-body
                url = "http://localhost:${sonarr.port}/api/v3/config/mediamanagement/1"
                request = "PUT"
                data = "@${
                  jsonFormat.generate "mediamanagement.json" {
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
                }"
              ''
            ]
            ++ (builtins.map (folder: ''
                url = "http://localhost:${sonarr.port}/api/v3/rootfolder"
                request = "POST"
                data = "@${jsonFormat.generate "rootfolder.json" folder}"
              '')
              sonarr.rootFolders)
            ++ (builtins.map (name: ''
              url = "http://localhost:${sonarr.port}/api/v3/downloadclient"
              request = "POST"
              data = "@${
                jsonFormat.generate "${name}.json" (
                  {
                    inherit name;
                    enable = true;
                    removeCompletedDownloads = true;
                    removeFailedDownloads = true;
                  }
                  // makeArrConfig sonarr.downloadClients.${name}
                )
              }"
            '') (builtins.attrNames sonarr.downloadClients))
        )
      }
    '';

    makeCurlScript = name: options: ctx: requests:
      pkgs.writeTextFile {
        inherit name;
        executable = true;
        text = ''
          #!${pkgs.curl}/bin/curl -K
          ${options}
          ${builtins.concatStringsSep "\nnext\n" (builtins.map (request: "${ctx}\n${request}") requests)}
        '';
      };
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
          -d "@${pkgs.writeText (builtins.toJSON data)}" &

      '';

    sonar-init = let
      curl =
        curl_base
        "$CREDENTIALS_DIRECTORY/api-key"
        "http://localhost:${config.services.sonarr.port}/api/v3";
      cfg = config.services.sonarr;
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
        }}

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
        }}

        # TODO: root folders

        # TODO: should be a map
        ${(curl "PUT" "/downloadclient" {
          importExtraFiles = true;
          extraFileExtensions = "srt";
          deleteEmptyFolders = true;

          # GUI defaults
          copyUsingHardlinks = true;
          recycleBinCleanupDays = 7;
          minimumFreeSpaceWhenImporting = 100;
          enableMediaInfo = true;
        })}

        wait
      '';
  in
    mkIf cfg.enable {
      systemd.services.sonarr = {
        serviceConfig = {
          # WorkingDirectory = cfg.dataDir;
          # ExecStartPre = "${jellyseerr-init}";
          ExecStart = lib.mkForce "${sonarr-init}";
          # ExecStartPost = "${jellyseerr-setup}";
          # ExecStartPost = "/srv/test.sh";
          LoadCredential = [];
        };
      };
    };
}
