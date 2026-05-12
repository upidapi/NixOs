{
  config,
  lib,
  mlib,
  inputs,
  pkgs,
  self,
  const,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  inherit (const) ports;
  mcfg = config.services.jellarr;
  cfg = config.modules.nixos.homelab.media.jellarr;
in {
  options.modules.nixos.homelab.media.jellarr = mkEnableOpt "";

  imports = [
    inputs.jellarr.nixosModules.default
  ];

  config = mkIf cfg.enable {
    sops.templates."jellarr-env".content = ''
      JELLARR_API_KEY="${config.sops.placeholder."jellyfin/jellyseerr-api-key"}"
    '';

    systemd.services.jellarr.serviceConfig.EnvironmentFile = [
      config.sops.templates."jellarr-env".path
    ];

    services.jellarr = {
      enable = true;

      # user = "jellyfin";
      # group = "media";

      config = {
        version = 1;

        base_url = "https://jellyfin.upidapi.dev";

        system = {
          pluginRepositories = [
            {
              enabled = true;
              name = "Jellyfin Stable";
              url = "https://repo.jellyfin.org/releases/plugin/manifest-stable.json";
            }
            {
              enabled = true;
              name = "Intro Skipper";
              url = "https://manifest.intro-skipper.org/manifest.json";
            }
            {
              enabled = true;
              name = "Merge Versions Plugin";
              url = "https://raw.githubusercontent.com/danieladov/JellyfinPluginManifest/master/manifest.json";
            }
            {
              enabled = true;
              name = "Meilisearch";
              url = "https://raw.githubusercontent.com/arnesacnussem/jellyfin-plugin-meilisearch/refs/heads/master/manifest.json";
            }
            {
              enabled = true;
              name = "Air Times";
              url = "https://raw.githubusercontent.com/apteryxxyz/jellyfin-plugin-airtimes/main/manifest.json";
            }
            {
              enabled = true;
              name = "InPlayerEpisodePreview";
              url = "https://raw.githubusercontent.com/Namo2/InPlayerEpisodePreview/master/manifest.json";
            }
            {
              enabled = true;
              name = "Streamyfin";
              url = "https://raw.githubusercontent.com/streamyfin/jellyfin-plugin-streamyfin/main/manifest.json";
            }
            {
              enabled = true;
              name = "Editor's Choice";
              url = "https://github.com/lachlandcp/jellyfin-editors-choice-plugin/raw/main/manifest.json";
            }
            {
              enabled = true;
              name = "JS Injector";
              url = "https://raw.githubusercontent.com/n00bcodr/jellyfin-plugins/main/10.11/manifest.json ";
            }
          ];
          # pluginRepositories = [
          #   {
          #     enabled = true;
          #     name = "Jellyfin Stable";
          #     url = "https://repo.jellyfin.org/files/plugin/manifest.json";
          #   }
          # ];

          enableMetrics = false;
          trickplayOptions = {
            enableHwAcceleration = true;
            enableHwEncoding = true;
          };
        };

        # plugins = [
        #   {
        #     name = "Air Times";
        #     configuration = {};
        #   }
        #
        #   {
        #     name = "EditorsChoice";
        #     configuration = {
        #       Mode = "NEW";
        #       NewTimeLimit = "1month";
        #
        #       EditorUserId = "d36f794e07e9451fa62ff76243f47a65";
        #       Heading = "New on Jellyfin / Recently Updated";
        #
        #       DoScriptInject = true;
        #       FileTransformation = false;
        #       HideOnTvLayout = false;
        #
        #       MinimumCriticRating = 8;
        #       MinimumRating = 8;
        #
        #       ShowDescription = true;
        #       ShowPlayed = true;
        #       ShowRandomMedia = false;
        #       ShowRating = true;
        #     };
        #   }
        #
        #   {
        #     name = "InPlayerEpisodePreview";
        #     configuration = {};
        #   }
        #
        #   {
        #     name = "Intro Skipper";
        #     configuration = {
        #       AutoDetectIntros = true;
        #       UpdateMediaSegments = true;
        #       CacheFingerprints = true;
        #
        #       ScanCommercial = true;
        #       ScanCredits = true;
        #       ScanIntroduction = true;
        #       ScanPreview = true;
        #       ScanRecap = true;
        #
        #       FileTransformationPluginEnabled = false;
        #       UseFileTransformationPlugin = false;
        #     };
        #   }
        #
        #   {
        #     name = "JavaScript Injector";
        #     configuration = let
        #       mkInjectRemoteScript = url:
        #       # javascript
        #       ''
        #         const script = document.createElement('script');
        #         script.src = `${url}`;
        #         script.async = true;
        #         document.head.appendChild(script);
        #       '';
        #     in {
        #       CustomJavaScripts = [
        #         {
        #           Name = "Kefin Tweaks";
        #           Enabled = true;
        #           RequiresAuthentication = false;
        #           Script = mkInjectRemoteScript "https://cdn.jsdelivr.net/gh/ranaldsgift/KefinTweaks@latest/kefinTweaks-plugin.js";
        #         }
        #         {
        #           Name = "jf-avatars";
        #           Enabled = true;
        #           RequiresAuthentication = false;
        #           Script = mkInjectRemoteScript "https://github.com/kalibrado/jf-avatars/releases/latest/download/main.js";
        #         }
        #       ];
        #     };
        #   }
        #
        #   {
        #     name = "Meilisearch";
        #     configuration = {
        #       Url = "http://127.0.0.1:7700";
        #       ApiKey = "1234";
        #       IndexName = "";
        #
        #       AttributesToSearchOn = ["name" "artists" "albumArtists" "originalTitle" "productionYear" "seriesName" "genres" "tags" "studios" "overview" "path"];
        #       Debug = false;
        #       FallbackToJellyfin = true;
        #     };
        #   }
        #
        #   {
        #     name = "Merge Versions";
        #     configuration = {};
        #   }
        #
        #   {
        #     name = "OMDb";
        #     configuration = {
        #       CastAndCrew = false;
        #     };
        #   }
        #
        #   {
        #     name = "Streamyfin";
        #     configuration = {
        #       Config = {
        #         settings = {
        #           jellyseerrServerUrl = {
        #             locked = true;
        #             value = "https://seerr.nelim.org";
        #           };
        #           rememberAudioSelections = {
        #             locked = false;
        #             value = true;
        #           };
        #           rememberSubtitleSelections = {
        #             locked = false;
        #             value = true;
        #           };
        #         };
        #       };
        #     };
        #   }
        #
        #   {
        #     name = "TheTVDB";
        #     configuration = {};
        #   }
        #
        #   {
        #     name = "TMDb";
        #     configuration = {};
        #   }
        # ];
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

          # {
          #   name = "Air Times";
          #   configuration = {};
          # }
          #
          # {
          #   name = "EditorsChoice";
          #   configuration = {
          #     Mode = "NEW";
          #     NewTimeLimit = "1month";
          #
          #     EditorUserId = "d36f794e07e9451fa62ff76243f47a65";
          #     Heading = "New on Jellyfin / Recently Updated";
          #
          #     DoScriptInject = true;
          #     FileTransformation = false;
          #     HideOnTvLayout = false;
          #
          #     MinimumCriticRating = 8;
          #     MinimumRating = 8;
          #
          #     ShowDescription = true;
          #     ShowPlayed = true;
          #     ShowRandomMedia = false;
          #     ShowRating = true;
          #   };
          # }
          #
          # {
          #   name = "InPlayerEpisodePreview";
          #   configuration = {};
          # }

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

              filetransformationpluginenabled = false;
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
                forwardSkipTime = {
                  value = 5;
                  locked = false;
                };
                rewindSkipTime = {
                  value = 5;
                  locked = false;
                };

                defaultBitrate = {
                  locked = false;
                  value = 2000000; # 2Mb/s (900MB/h)
                };

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
