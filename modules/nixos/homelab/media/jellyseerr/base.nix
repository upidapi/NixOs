{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types mkIf;
  inherit (builtins) toString;
in {
  # {
  #  "clientId": "c6f778e9-3e0e-4328-88dd-992ed6dfabaa",
  #  "vapidPrivate": "gkTKTT1l7g5tYusIuowYXLUbeAuwQFyHZdHv8W8qtdA",
  #  "vapidPublic": "BFRlIcvG5XxOPlH1OJpTf7qfVbnGScg7pEa6KGIQ8Lik0OAutWXZtoqoLNfbceoCPITQevd-ohOuFlxwAx7nyWQ",
  #  "main": {
  #   "apiKey": "MTc0OTQ4ODY0NjY4NjQzYTRmZWRjLWQxMTEtNDRlOS05NjA3LTc0YTFiMDM1MGM1ZQ==",
  #   "applicationTitle": "Jellyseerr",
  #   "applicationUrl": "",
  #   "cacheImages": false,
  #   "defaultPermissions": 32,
  #   "defaultQuotas": {
  #    "movie": {},
  #    "tv": {}
  #   },
  #   "hideAvailable": false,
  #   "localLogin": true,
  #   "mediaServerLogin": true,
  #   "newPlexLogin": true,
  #   "discoverRegion": "",
  #   "streamingRegion": "",
  #   "originalLanguage": "",
  #   "mediaServerType": 2,
  #   "partialRequestsEnabled": true,
  #   "enableSpecialEpisodes": false,
  #   "locale": "en"
  #  },
  #  "plex": {
  #   "name": "",
  #   "ip": "",
  #   "port": 32400,
  #   "useSsl": false,
  #   "libraries": []
  #  },
  #  "jellyfin": {
  #   "name": "upinix-laptop",
  #   "ip": "127.0.0.1",
  #   "port": 8096,
  #   "useSsl": false,
  #   "urlBase": "",
  #   "externalHostname": "",
  #   "jellyfinForgotPasswordUrl": "",
  #   "libraries": [
  #    {
  #     "id": "f137a2dd21bbc1b99aa5c0f6bf02a805",
  #     "name": "Movies",
  #     "enabled": true,
  #     "type": "movie"
  #    },
  #    {
  #     "id": "a656b907eb3a73532e40e44b968d0225",
  #     "name": "Shows",
  #     "enabled": true,
  #     "type": "show"
  #    }
  #   ],
  #   "serverId": "cd69c8b59e5b482eacf8ea3ff8c7f5ff",
  #   "apiKey": "6a8ca592b1bb4287b037e8a54fa6d707"
  #  },
  #  "tautulli": {},
  #  "radarr": [
  #   {
  #    "name": "radarr",
  #    "hostname": "127.0.0.1",
  #    "port": 7878,
  #    "apiKey": "ad31cf5ff0124e439b23067391f4b6de",
  #    "useSsl": false,
  #    "activeProfileId": 1,
  #    "activeProfileName": "Any",
  #    "activeDirectory": "/srv/radarr",
  #    "is4k": false,
  #    "minimumAvailability": "released",
  #    "tags": [],
  #    "isDefault": true,
  #    "syncEnabled": false,
  #    "preventSearch": false,
  #    "tagRequests": false,
  #    "id": 0
  #   }
  #  ],
  #  "sonarr": [
  #   {
  #    "name": "sonarr",
  #    "hostname": "127.0.0.1",
  #    "port": 8989,
  #    "apiKey": "bafd0de9bc384a17881f27881a5c5e72",
  #    "useSsl": false,
  #    "activeProfileId": 1,
  #    "activeProfileName": "Any",
  #    "activeDirectory": "/srv/sonarr",
  #    "tags": [],
  #    "animeTags": [],
  #    "is4k": false,
  #    "isDefault": true,
  #    "enableSeasonFolders": false,
  #    "syncEnabled": false,
  #    "preventSearch": false,
  #    "tagRequests": false,
  #    "id": 0
  #   }
  #  ],
  #  "public": {
  #   "initialized": true
  #  },
  #  "notifications": {
  #   "agents": {
  #    "email": {
  #     "enabled": false,
  #     "options": {
  #      "userEmailRequired": false,
  #      "emailFrom": "",
  #      "smtpHost": "",
  #      "smtpPort": 587,
  #      "secure": false,
  #      "ignoreTls": false,
  #      "requireTls": false,
  #      "allowSelfSigned": false,
  #      "senderName": "Jellyseerr"
  #     }
  #    },
  #    "discord": {
  #     "enabled": false,
  #     "types": 0,
  #     "options": {
  #      "webhookUrl": "",
  #      "webhookRoleId": "",
  #      "enableMentions": true
  #     }
  #    },
  #    "lunasea": {
  #     "enabled": false,
  #     "types": 0,
  #     "options": {
  #      "webhookUrl": ""
  #     }
  #    },
  #    "slack": {
  #     "enabled": false,
  #     "types": 0,
  #     "options": {
  #      "webhookUrl": ""
  #     }
  #    },
  #    "telegram": {
  #     "enabled": false,
  #     "types": 0,
  #     "options": {
  #      "botAPI": "",
  #      "chatId": "",
  #      "messageThreadId": "",
  #      "sendSilently": false
  #     }
  #    },
  #    "pushbullet": {
  #     "enabled": false,
  #     "types": 0,
  #     "options": {
  #      "accessToken": ""
  #     }
  #    },
  #    "pushover": {
  #     "enabled": false,
  #     "types": 0,
  #     "options": {
  #      "accessToken": "",
  #      "userToken": "",
  #      "sound": ""
  #     }
  #    },
  #    "webhook": {
  #     "enabled": false,
  #     "types": 0,
  #     "options": {
  #      "webhookUrl": "",
  #      "jsonPayload": "IntcbiAgXCJub3RpZmljYXRpb25fdHlwZVwiOiBcInt7bm90aWZpY2F0aW9uX3R5cGV9fVwiLFxuICBcImV2ZW50XCI6IFwie3tldmVudH19XCIsXG4gIFwic3ViamVjdFwiOiBcInt7c3ViamVjdH19XCIsXG4gIFwibWVzc2FnZVwiOiBcInt7bWVzc2FnZX19XCIsXG4gIFwiaW1hZ2VcIjogXCJ7e2ltYWdlfX1cIixcbiAgXCJ7e21lZGlhfX1cIjoge1xuICAgIFwibWVkaWFfdHlwZVwiOiBcInt7bWVkaWFfdHlwZX19XCIsXG4gICAgXCJ0bWRiSWRcIjogXCJ7e21lZGlhX3RtZGJpZH19XCIsXG4gICAgXCJ0dmRiSWRcIjogXCJ7e21lZGlhX3R2ZGJpZH19XCIsXG4gICAgXCJzdGF0dXNcIjogXCJ7e21lZGlhX3N0YXR1c319XCIsXG4gICAgXCJzdGF0dXM0a1wiOiBcInt7bWVkaWFfc3RhdHVzNGt9fVwiXG4gIH0sXG4gIFwie3tyZXF1ZXN0fX1cIjoge1xuICAgIFwicmVxdWVzdF9pZFwiOiBcInt7cmVxdWVzdF9pZH19XCIsXG4gICAgXCJyZXF1ZXN0ZWRCeV9lbWFpbFwiOiBcInt7cmVxdWVzdGVkQnlfZW1haWx9fVwiLFxuICAgIFwicmVxdWVzdGVkQnlfdXNlcm5hbWVcIjogXCJ7e3JlcXVlc3RlZEJ5X3VzZXJuYW1lfX1cIixcbiAgICBcInJlcXVlc3RlZEJ5X2F2YXRhclwiOiBcInt7cmVxdWVzdGVkQnlfYXZhdGFyfX1cIixcbiAgICBcInJlcXVlc3RlZEJ5X3NldHRpbmdzX2Rpc2NvcmRJZFwiOiBcInt7cmVxdWVzdGVkQnlfc2V0dGluZ3NfZGlzY29yZElkfX1cIixcbiAgICBcInJlcXVlc3RlZEJ5X3NldHRpbmdzX3RlbGVncmFtQ2hhdElkXCI6IFwie3tyZXF1ZXN0ZWRCeV9zZXR0aW5nc190ZWxlZ3JhbUNoYXRJZH19XCJcbiAgfSxcbiAgXCJ7e2lzc3VlfX1cIjoge1xuICAgIFwiaXNzdWVfaWRcIjogXCJ7e2lzc3VlX2lkfX1cIixcbiAgICBcImlzc3VlX3R5cGVcIjogXCJ7e2lzc3VlX3R5cGV9fVwiLFxuICAgIFwiaXNzdWVfc3RhdHVzXCI6IFwie3tpc3N1ZV9zdGF0dXN9fVwiLFxuICAgIFwicmVwb3J0ZWRCeV9lbWFpbFwiOiBcInt7cmVwb3J0ZWRCeV9lbWFpbH19XCIsXG4gICAgXCJyZXBvcnRlZEJ5X3VzZXJuYW1lXCI6IFwie3tyZXBvcnRlZEJ5X3VzZXJuYW1lfX1cIixcbiAgICBcInJlcG9ydGVkQnlfYXZhdGFyXCI6IFwie3tyZXBvcnRlZEJ5X2F2YXRhcn19XCIsXG4gICAgXCJyZXBvcnRlZEJ5X3NldHRpbmdzX2Rpc2NvcmRJZFwiOiBcInt7cmVwb3J0ZWRCeV9zZXR0aW5nc19kaXNjb3JkSWR9fVwiLFxuICAgIFwicmVwb3J0ZWRCeV9zZXR0aW5nc190ZWxlZ3JhbUNoYXRJZFwiOiBcInt7cmVwb3J0ZWRCeV9zZXR0aW5nc190ZWxlZ3JhbUNoYXRJZH19XCJcbiAgfSxcbiAgXCJ7e2NvbW1lbnR9fVwiOiB7XG4gICAgXCJjb21tZW50X21lc3NhZ2VcIjogXCJ7e2NvbW1lbnRfbWVzc2FnZX19XCIsXG4gICAgXCJjb21tZW50ZWRCeV9lbWFpbFwiOiBcInt7Y29tbWVudGVkQnlfZW1haWx9fVwiLFxuICAgIFwiY29tbWVudGVkQnlfdXNlcm5hbWVcIjogXCJ7e2NvbW1lbnRlZEJ5X3VzZXJuYW1lfX1cIixcbiAgICBcImNvbW1lbnRlZEJ5X2F2YXRhclwiOiBcInt7Y29tbWVudGVkQnlfYXZhdGFyfX1cIixcbiAgICBcImNvbW1lbnRlZEJ5X3NldHRpbmdzX2Rpc2NvcmRJZFwiOiBcInt7Y29tbWVudGVkQnlfc2V0dGluZ3NfZGlzY29yZElkfX1cIixcbiAgICBcImNvbW1lbnRlZEJ5X3NldHRpbmdzX3RlbGVncmFtQ2hhdElkXCI6IFwie3tjb21tZW50ZWRCeV9zZXR0aW5nc190ZWxlZ3JhbUNoYXRJZH19XCJcbiAgfSxcbiAgXCJ7e2V4dHJhfX1cIjogW11cbn0i"
  #     }
  #    },
  #    "webpush": {
  #     "enabled": false,
  #     "options": {}
  #    },
  #    "gotify": {
  #     "enabled": false,
  #     "types": 0,
  #     "options": {
  #      "url": "",
  #      "token": ""
  #     }
  #    }
  #   }
  #  },
  #  "network": {
  #   "csrfProtection": false,
  #   "trustProxy": false,
  #   "forceIpv4First": false,
  #   "proxy": {
  #    "enabled": false,
  #    "hostname": "",
  #    "port": 8080,
  #    "useSsl": false,
  #    "user": "",
  #    "password": "",
  #    "bypassFilter": "",
  #    "bypassLocalAddresses": true
  #   }
  #  }
  # }

  options.services.jellyseerr = {
    settings = mkOption {
      description = ''
        Mimics jellyseers settings.json, refer to it for info. Most options
        will be auto generated by jellyseer if not provided.

        jellyfin.libraries.[].id will be autogenerated
      '';
      type = types.attrs;
      default = {};
    };
    force = mkOption {
      description = ''
        If false, then it will only create the config.json if it doesn't
        already exist. If true however, all options are overriden each time the
        service is started. Which means any changes through the Jellyseerr GUI
        will have no effect after a service restarts.
      '';
      type = types.bool;
    };
    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/jellyseerr";
    };
    apiKeyFile = mkOption {
      type = types.str;
    };
    jellyfin = {
      apiKeyFile = mkOption {
        type = types.path;
      };
      passwordFile = mkOption {
        type = types.path;
      };
      username = mkOption {
        type = types.str;
      };
    };
    adminEmail = mkOption {
      type = types.str;
    };
    # settings = {
    #   jellyfin = {
    #     libraries = lib.attrsOf (types.submodule ({name, ...}: {
    #       name = mkOption {
    #         type = types.str;
    #         default = name;
    #         example = "Movies";
    #       };
    #       type = mkEnum ["movie" "show"]; # Might be more idk
    #       enable = mkOption {
    #         type = types.bool;
    #         default = true;
    #       };
    #       id = mkOption {
    #         type = types.nullOr types.str;
    #         default = null;
    #         description = ''
    #           The id of the folder, this will be automatically generated
    #         '';
    #       };
    #     }));
    #   };
    # };
  };

  config = let
    cfg = config.services.jellyseerr;
    genfolderuuid =
      pkgs.writeShellScript "genfolderuuid"
      # bash
      ''
        key="root\\default\\$1"
        type="mediabrowser.controller.entities.collectionfolder"

        # concatenate type.fullname + key
        input="''${type}''${key}"

        # convert to utf-16le and hash with md5
        md5hex=$(echo -n "$input" | ${pkgs.iconv}/bin/iconv -f utf-8 -t utf-16le | md5sum | ${pkgs.gawk}/bin/awk '{print $1}')

        # format as guid with .net byte order (little-endian for first 3 fields)
        a="''${md5hex:6:2}''${md5hex:4:2}''${md5hex:2:2}''${md5hex:0:2}"
        b="''${md5hex:10:2}''${md5hex:8:2}"
        c="''${md5hex:14:2}''${md5hex:12:2}"
        d="''${md5hex:16:4}"
        e="''${md5hex:20:12}"

        guid="''${a}''${b}''${c}''${d:0:4}''${d:4:8}''${e}"

        # lowercase to match .net format
        echo "$(echo $guid | tr '[:upper:]' '[:lower:]')"
      '';

    settings = builtins.toJSON cfg.settings;

    jellyseerr-init =
      pkgs.writeShellScript "jellyseerr-init"
      ''
        settings="$CREDENTIALS_DIRECTORY/config"
        cfg="${config.services.jellyseerr.configDir}/settings.json"

        mkdir -p $(dirname $cfg)
        touch $cfg

        # Generate the library ids
        new_ids_json=$(cat "$settings" |\
          ${pkgs.jq}/bin/jq -r '.jellyfin.libraries[].name' |\
          while IFS= read -r name; do
           ${genfolderuuid} "$name"
          done |\
          ${pkgs.jq}/bin/jq -R -s 'split("\n") | .[:-1]')

        echo "$json_data" |\
          ${pkgs.jq}/bin/jq \
          --argjson new_ids "$new_ids_json" \
          '.jellyfin.libraries |= (reduce (to_entries[]) as $entry ([]; . + [ $entry.value | .id = $new_ids[$entry.key] ]))'


        cat "$cfg" "$settings" |\
          ${pkgs.jq}/bin/jq --slurp 'reduce .[] as $item ({}; . * $item)' \
          > $cfg
      '';

    # https://gist.github.com/nielsvanvelzen/ea047d9028f676185832e51ffaf12a6f

    jellyfinPort = config.services.declarative-jellyfin.network.internalHttpPort;

    jellyseerr-setup =
      pkgs.writeShellScript "jellyseerr-setup"
      ''
        jellyserr_api_key="$(cat $CREDENTIALS_DIRECTORY/jellyserr_api_key)"
        jellyfin_api_key="$(cat $CREDENTIALS_DIRECTORY/jellyfin_api_key)"
        jellyfin_password="$(cat $CREDENTIALS_DIRECTORY/jellyfin_password)"

        db_file="config/db/db.sqlite3"

        echo "start"

        while ! [ -f "$db_file" ]; do
          # echo "Waiting for db: $db_file"
          sleep 1
        done

        echo "a"

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

        echo "b"

        # only setup if there are no users
        users="$(${pkgs.sqlite}/bin/sqlite3 $db_file "SELECT * FROM user")"
        if [ -n "$users" ]; then
          exit 0
        fi

        echo "c"

        # you cant create a user if there is none
        ${pkgs.sqlite}/bin/sqlite3 $db_file "
        INSERT INTO user (
            email,
            avatar
        ) values (
            'TEMP_EMAIL',
            'TEMP_AVATAR'
        )
        "

        echo "d"

        # Wait for jellyfin to start
        while true; do
          ${pkgs.curl}/bin/curl -X GET \
            "http://127.0.0.1:${toString jellyfinPort}/System/Ping" \
          > /dev/null 2>&1

          if [ $? -eq 0 ]; then
            break
          fi

          sleep 1
        done

        echo "d2"

        while true; do
          # use the api to create the admin user
          res=$(
            ${pkgs.curl}/bin/curl -X POST \
              -H "X-Api-Key: $jellyserr_api_key" \
              -H "Content-Type: application/json" \
              "http://127.0.0.1:${toString cfg.port}/api/v1/auth/jellyfin" \
              -d "{
                \"email\": \"${cfg.adminEmail}\",
                \"username\": \"${cfg.jellyfin.username}\",
                \"password\": \"$jellyfin_password\"
              }"
          )

          # You get this if jellyseerr cant connect to jellyfin
          if [ "$res" != '{"message":"Something went wrong."}' ]; then
            echo "$res"
            break
          fi

          sleep 1
        done

        echo "e"

        ${pkgs.sqlite}/bin/sqlite3 $db_file "
        DELETE FROM user
        WHERE id = 1;
        "

        echo "f"

        # make the created user the admin user
        ${pkgs.sqlite}/bin/sqlite3 $db_file "
        UPDATE user
        SET
            id = 1,
            permissions = 2,
            jellyfinAuthToken = '$jellyfin_api_key',
            password = NULL
        WHERE
            id = 2;
        "

        echo "g"
      '';
  in
    mkIf cfg.enable {
      sops.templates."jellyseerr-config.json".content = settings;

      systemd.services.jellyseerr = {
        after = ["jellyfin.service"];
        serviceConfig = {
          WorkingDirectory = cfg.dataDir;
          ExecStartPre = "${jellyseerr-init}";
          ExecStartPost = "${jellyseerr-setup}";
          # ExecStartPost = "/srv/test.sh";
          LoadCredential = [
            "config:${config.sops.templates."jellyseerr-config.json".path}"

            "jellyserr_api_key:${cfg.apiKeyFile}"
            "jellyfin_api_key:${cfg.jellyfin.apiKeyFile}"
            "jellyfin_password:${cfg.jellyfin.passwordFile}"
          ];
        };
      };

      # systemd.services.jellyseerr.serviceConfig.ExecStart =
      #   lib.mkForce "cat ${config.services.jellyseerr.configDir}/settings.json";
    };
}
