{
  config,
  lib,
  mlib,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.homelab.media.jellarr;
in {
  options.modules.nixos.homelab.media.jellarr = mkEnableOpt "";

  imports = [
    inputs.jellarr.nixosModules.default
  ];

  config = mkIf cfg.enable {
    services.jellarr = {
      config = {
        version = 1;

        base_url = "https://jellyfin.upidapi.dev";

        branding = {
          loginDisclaimer = "";
          splashscreenEnabled = false;
        };

        users = lib.values (lib.mapAttrs (user: v:
          v
          // {
            name = user;
            policy = {
              isAdministrator = false;
              loginAttemptsBeforeLockout = -1;
            };

            passwordFile = config.sops.secrets."jellyfin/users/${user}/password".path;
          }) {
          admin.permissions.isAdministrator = true;
          smiley = {};
          mari = {};
          pablo = {};
          cave.maxParentalRatingSubScore = 17;
          tv.maxParentalRatingSubScore = 13;

          # from: GET jellyfin/Localization/ParentalRatings
          # https://www.motionpictures.org/film-ratings/

          # NC-17 (adults only / anything)
          guest-1 = {};
          guest-2 = {};
          guest-3 = {};
          guest-4 = {};
          guest-5 = {};
          guest-6 = {};
          guest-7 = {};
          guest-8 = {};
          # R
          guest-17-1.maxParentalRatingSubScore = 17;
          guest-17-2.maxParentalRatingSubScore = 17;
          guest-17-3.maxParentalRatingSubScore = 17;
          guest-17-4.maxParentalRatingSubScore = 17;
          # PG-13
          guest-13-1.maxParentalRatingSubScore = 13;
          guest-13-2.maxParentalRatingSubScore = 13;
          guest-13-3.maxParentalRatingSubScore = 13;
          guest-13-4.maxParentalRatingSubScore = 13;
          # PG
          guest-10-1.maxParentalRatingSubScore = 10;
          guest-10-2.maxParentalRatingSubScore = 10;
          guest-10-3.maxParentalRatingSubScore = 10;
          guest-10-4.maxParentalRatingSubScore = 10;
          # G
          guest-0-1.maxParentalRatingSubScore = 0;
          guest-0-2.maxParentalRatingSubScore = 0;
          guest-0-3.maxParentalRatingSubScore = 0;
          guest-0-4.maxParentalRatingSubScore = 0;
        });

        # https://github.com/venkyr77/jellarr/issues/48
        # concurrent runs causes duplicates

        library.virtualFolders = [
          {
            name = "Movies";
            collectionType = "movies";
            libraryOptions = {
              pathInfos = [
                {path = "/raid/media/movies";}
              ];
            };
          }
          {
            name = "Shows";
            collectionType = "tvshows";
            libraryOptions = {
              pathInfos = [
                {path = "/raid/media/tv";}
              ];
            };
          }
        ];

        encoding = {
          enableDecodingColorDepth10HevcRext = false;
          enableDecodingColorDepth10Vp9 = true;
          enableDecodingColorDepth12HevcRext = false;

          enableHardwareEncoding = true;
          hardwareAccelerationType = "nvenc";
          enableDecodingColorDepth10Hevc = true;
          allowHevcEncoding = true;
          allowAv1Encoding = false;

          hardwareDecodingCodecs = [
            "h264"
            "hevc"
            "mpeg2video"
            "vc1"
            "vp9"
            # "av1" # not supported by my gpu
          ];
        };

        system = {
          # FIXME: not supported yet with Jellarr?
          /*
          serverName = "Jelly";
          quickConnectAvailable = false;
          isStartupWizardCompleted = true;

          enableGroupingMoviesIntoCollections = true;
          enableGroupingShowsIntoCollections = true;
          enableExternalContentInSuggestions = false;

          enableSlowResponseWarning = false;

          network = {
            internalHttpPort = ports.jellyfin;
            publicHttpPort = ports.jellyfin;
          };
          */

          pluginRepositories = [
            {
              enable = true;
              name = "Jellyfin Stable";
              url = "https://repo.jellyfin.org/files/plugin/manifest.json";
            }
          ];

          enableMetrics = false;

          trickplayOptions = {
            enableHwAcceleration = true;
            enableHwEncoding = true;
          };
        };

        plugins = [
          {
            name = "Studio Images";
            configuration.RepositoryUrl = "https://raw.githubusercontent.com/jellyfin/emby-artwork/master/studios";
          }
          {
            name = "MusicBrainz";
            configuration = {
              Server = "https://musicbrainz.org";
              RateLimit = 1;
              ReplaceArtistName = false;
            };
          }
          {
            name = "AudioDB";
            configuration.ReplaceAlbumName = "false";
          }

          {
            name = "Air Times";
            configuration = {};
          }

          {
            name = "EditorsChoice";
            configuration = {
              Mode = "NEW";
              NewTimeLimit = "1month";

              EditorUserId = "d36f794e07e9451fa62ff76243f47a65";
              Heading = "New on Jellyfin / Recently Updated";

              DoScriptInject = true;
              FileTransformation = false;
              HideOnTvLayout = false;

              MinimumCriticRating = 8;
              MinimumRating = 8;

              ShowDescription = true;
              ShowPlayed = true;
              ShowRandomMedia = false;
              ShowRating = true;
            };
          }

          {
            name = "InPlayerEpisodePreview";
            configuration = {};
          }

          {
            name = "Intro Skipper";
            configuration = {
              AutoDetectIntros = true;
              UpdateMediaSegments = true;
              CacheFingerprints = true;

              ScanCommercial = true;
              ScanCredits = true;
              ScanIntroduction = true;
              ScanPreview = true;
              ScanRecap = true;

              FileTransformationPluginEnabled = false;
              UseFileTransformationPlugin = false;
            };
          }

          # {
          #   name = "JavaScript Injector";
          #   configuration = let
          #     mkInjectRemoteScript = url:
          #     # javascript
          #     ''
          #       const script = document.createElement('script');
          #       script.src = `${url}`;
          #       script.async = true;
          #       document.head.appendChild(script);
          #     '';
          #   in {
          #     CustomJavaScripts = [
          #       {
          #         Name = "Kefin Tweaks";
          #         Enabled = true;
          #         RequiresAuthentication = false;
          #         Script = mkInjectRemoteScript "https://cdn.jsdelivr.net/gh/ranaldsgift/KefinTweaks@latest/kefinTweaks-plugin.js";
          #       }
          #       {
          #         Name = "jf-avatars";
          #         Enabled = true;
          #         RequiresAuthentication = false;
          #         Script = mkInjectRemoteScript "https://github.com/kalibrado/jf-avatars/releases/latest/download/main.js";
          #       }
          #     ];
          #   };
          # }

          # TODO: Meilisearch
          # {
          #   name = "Meilisearch";
          #   configuration = {
          #     Url = "http://127.0.0.1:7700";
          #     ApiKey = "1234";
          #     IndexName = "";
          #
          #     AttributesToSearchOn = ["name" "artists" "albumArtists" "originalTitle" "productionYear" "seriesName" "genres" "tags" "studios" "overview" "path"];
          #     Debug = false;
          #     FallbackToJellyfin = true;
          #   };
          # }

          {
            name = "Merge Versions";
            configuration = {};
          }

          {
            name = "Streamyfin";
            configuration = {
              Config.settings = {
                jellyseerrServerUrl = {
                  locked = true;
                  value = "https://jellyseerr.upidapi.dev";
                };
                rememberAudioSelections = {
                  locked = false;
                  value = true;
                };
                rememberSubtitleSelections = {
                  locked = false;
                  value = true;
                };
              };
            };
          }

          {
            name = "OMDb";
            configuration = {
              CastAndCrew = false;
            };
          }
          {
            name = "TheTVDB";
            configuration = {};
          }
          {
            name = "TMDb";
            configuration = {
              TmdbApiKey = "";
              IncludeAdult = false;
              ExcludeTagsSeries = false;
              ExcludeTagsMovies = false;
              ImportSeasonName = false;
              MaxCastMembers = 15;
              MaxCrewMembers = 15;
              HideMissingCastMembers = false;
              HideMissingCrewMembers = false;
              PosterSize = "original";
              BackdropSize = "original";
              LogoSize = "original";
              ProfileSize = "original";
              StillSize = "original";
            };
          }
        ];
      };
    };
  };
}
