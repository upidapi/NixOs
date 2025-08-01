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
    instanceName ? null,
    dataDir,
    appUrl,
    enableNaming ? false,
    namingDefault ? {},
    enableRootFolders ? false,
    enableQuality ? false,
    enableMediaManagement ? false,
    enableIndexers ? false,
    enableIndexerProxies ? false,
    enableApplications ? false,
  }: let
    cfg = config.services.${serviceName};
    s = cfg.extraSettings;

    curl' =
      curl_base
      cfg.apiKeyFile
      appUrl;
    curl = type: url: curl' type url "";

    tryGetAttrs = g: attrs: (
      lib.getAttrs (lib.intersectLists (lib.attrNames attrs) g) attrs
    );
    tags = lib.pipe s [
      (tryGetAttrs ["indexers" "indexerProxies"])
      lib.attrValues
      (lib.map (a: lib.mapAttrsToList (_: v: v.tags or []) a))
      lib.concatLists
      lib.concatLists
      lib.unique
    ];
    mapTags = let
      tm = lib.pipe tags [
        (lib.imap1 (i: v: {
          name = v;
          value = i;
        }))
        lib.listToAttrs
      ];
    in
      d: {
        tags =
          lib.map
          (t: tm.${t})
          (d.tags or []);
      };

    qualityDefaults = builtins.fromJSON (builtins.readFile ./quality-${serviceName}.json);

    quality = lib.map (quality: let
      q = quality.bitrate;

      d =
        lib.findFirst
        (qu: qu.title == quality.name)
        (lib.throw "the quality \"${q.name}\" does not exist")
        qualityDefaults;
      # # nf = a: b: if a == null || b == null then null else lib.min a b;
      # nmin = a: b:
      #   if a == null
      #   then b
      #   else if b == null
      #   then a
      #   else lib.min a b;
      # nmax = a: b:
      #   if a == null || b == null
      #   then null
      #   else lib.max a b;
      #
      # clamp = lMin: c: lMax: da:
      #   da
      #   // {
      #     ${c} =
      #       nmin
      #       (nmax (lib.foldl nmax lMin) da.${c})
      #       (lib.foldl nmin lMax);
      #   };
      #
      # res =
      #   lib.pipe {
      #     min = q.min null;
      #     preferred = q.preferred or null;
      #     max = q.max or null;
      #   } [
      #     (clamp ["min"] "preferred" ["max"])
      #     (clamp [] "min" ["preferred" "max"])
      #     (clamp ["min" "preferred"] "max" [])
      #   ];
    in
      d
      // (
        if q == null
        then {}
        else {
          minSize = q.min;
          preferredSize = q.preferred;
          maxSize = q.max;
          inherit (quality) title;
        }
      ))
    (lib.attrValues s.quality);

    # Could in theory update based on name instead of recreating all it get id
    # based on name, then update that id delete all ids not corresponding to a
    # name.
    # But i think that's error prone and non practical
    mapArrReqs' = name: apiPath: cond: data:
      lib.optionalString cond
      # bash
      ''
        echo "Deleting old ${name}"
        delete-all "${apiPath}"

        echo "Creating ${name}"
        ${lib.concatStringsSep "\n\n" data}
      '';

    mapArrReqs = name: apiPath: cond: attrs: f:
      mapArrReqs' name apiPath cond (
        lib.imap1 f
        (lib.mapAttrsToList
          (n: v: {name = n;} // v)
          attrs)
      );

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
                '$.apikey' \
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
                instanceName =
                  if instanceName == null
                  then serviceName
                  else instanceName;

                branch = "main";
                logLevel = "debug";
                consoleLogLevel = "";
                logSizeLimit = 1;
                updateScriptPath = "";
              }
              // s.host)}

          echo "Configuring quality"
          ${lib.optionalString enableQuality (
            curl "PUT" "/qualitydefinition/update" quality
          )}

          echo "Configuring naming"
          ${lib.optionalString enableNaming (
            curl "PUT" "/config/naming/1" (
              {id = 1;}
              // namingDefault
              // s.naming
            )
          )}

          echo "Configuring media management"
          ${lib.optionalString enableMediaManagement (
            curl "PUT" "/config/mediamanagement/1" ({
                id = 1;
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
              }
              // s.mediaManagement)
          )}

          delete-one () {
            ${curl "DELETE" "/$1/$2" {}} #
          }

          delete-all () {
            ids=$(${curl "GET" "/$1" {}} | jq ".[].id")

            for id in $ids; do
              delete-one "$1" "$id"
            done
          }

          ${mapArrReqs' "root folders" "rootfolder"
            enableRootFolders
            (map
              (d: curl "POST" "/rootfolder" {path = d;})
              s.rootFolders)}

          ${mapArrReqs "download clients" "downloadclient" true
            s.downloadClients
            (_: d: (
              curl' "POST" "/downloadclient" ''
                | json-file-resolve \
                  '$.fields[?(@.name=="password")].value' \
              '' ({
                  categories = [];
                  priority = 25;
                }
                // (mkArrContract d))
            ))} #

          ${mapArrReqs' "tags" "tag" true
            (map
              (d: curl "POST" "/tag" {label = d;})
              tags)}

          ${mapArrReqs "indexer proxies" "indexerProxy"
            enableIndexerProxies
            s.indexerProxies
            (_: d: (
              curl "POST" "/indexerProxy"
              ((
                  mkArrContract
                  (d // {implementation = d.name;})
                )
                // (mapTags d))
            ))}

          ${mapArrReqs "indexers" "indexer"
            enableIndexers
            s.indexers
            (_: d: (
              curl' "POST" "/indexer" ''
                | json-file-resolve \
                  '$.fields[?(@.name=="password")].value' \
              '' ({
                  appProfileId = 1;
                  priority = 25;
                }
                // (mkArrContract d)
                // (mapTags d))
            ))}

          ${mapArrReqs "applications" "applications"
            enableApplications
            s.applications
            (_: d: (
              curl' "POST" "/applications" ''
                | json-file-resolve \
                  '$.fields[?(@.name=="apiKey")].value' \
              '' ({
                  appProfileId = 1;
                }
                // (mkArrContract d))
            ))}

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
              ++ lib.optional enableQuality "quality"
              ++ lib.optional enableIndexers "indexers"
              ++ lib.optional enableIndexers "indexerProxies"
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
              indexerProxies = mkOption {
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
              quality = mkOption {
                type = types.attrsOf (types.submodule ({name, ...}: {
                  options = {
                    name = mkOption {
                      type = types.enum (map (q: q.title) qualityDefaults);
                      default = name;
                    };
                    title = mkOption {
                      type = types.str;
                      default = name;
                    };
                    bitrate = mkOption {
                      description = ''
                        Messured in MB/min (Megabytes Per Minute). Set to null
                        for unlimited.
                      '';
                      type = types.nullOr (types.submodule {
                        options = {
                          min = mkOption {
                            type = types.int;
                          };
                          preferred = mkOption {
                            type = types.nullOr types.int;
                          };
                          max = mkOption {
                            type = types.nullOr types.int;
                          };
                        };
                      });
                    };
                  };
                }));
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
                example = ["/media/${serviceName}"];
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

    config = lib.mkIf cfg.enable {
      assertions =
        lib.mapAttrsToList (
          _: co: let
            c = co.bitrate;
          in {
            assertion =
              if c == null
              then true
              else let
                nmax = a: b:
                  if a == null || b == null
                  then null
                  else lib.max a b;
                isInc = a: b: nmax a b == b;
              in
                (isInc c.min c.preferred)
                && (isInc c.preferred c.max);
            message = "bitrate for ${co.name}; min, prefered, max, must be in non decreasing order";
          }
        )
        cfg.extraSettings.quality or {};

      systemd.services.${serviceName} = {
        after = ["qbittorrent.service"];
        serviceConfig = {
          # User = serviceName;
          ExecStart = lib.mkForce "${lib.getExe init-script}";
        };
      };
    };
  };
in {
  imports = [
    (mkArrConfig {
      serviceName = "sonarr";
      instanceName = "Sonarr";
      dataDir = "${config.services.sonarr.dataDir}";
      appUrl = "http://localhost:${toString config.services.sonarr.settings.server.port}/api/v3";

      enableNaming = true;
      namingDefault = {
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
      enableRootFolders = true;
      enableMediaManagement = true;
      enableQuality = true;
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
      enableQuality = true;
    })

    (mkArrConfig {
      serviceName = "prowlarr";
      dataDir = config.services.prowlarr.dataDir;
      appUrl = "http://localhost:${toString config.services.prowlarr.settings.server.port}/localhost/api/v1";

      enableIndexers = true;
      enableIndexerProxies = true;
      enableApplications = true;
    })
  ];
}
