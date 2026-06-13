{
  config,
  lib,
  mlib,
  const,
  pkgs,
  inputs,
  self,
  ...
}: let
  inherit (const) ports;
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.homelab.media.jellyfin;
  jcfg = config.services.declarative-jellyfin;
in {
  options.modules.nixos.homelab.media.jellyfin =
    mkEnableOpt
    "enables jellyfin for local movie hosting";

  imports = [
    inputs.declarative-jellyfin.nixosModules.default
  ];
  # https://git.spoodythe.one/spoody/declarative-jellyfin

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings = {
      "jellyfin-dir-create" = {
        "/var/lib/jellyfin/jellyfin-web".d = {
          group = "jellyfin";
          user = "jellyfin";
          mode = "750";
        };
        "/var/lib/jellyfin/config".d = {
          group = "jellyfin";
          user = "jellyfin";
          mode = "750";
        };
      };
    };

    # NOTE: if transcoding fails, try to restsrt
    #  >>> nvidia-smi
    #  Failed to initialize NVML: Driver/library version mismatch
    #  NVML library version: 595.58
    hardware = {
      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          libva-vdpau-driver
          libvdpau-va-gl
          nvidia-vaapi-driver
          libva
        ];
        extraPackages32 = with pkgs; [libva-vdpau-driver];
      };
    };

    environment.systemPackages = with pkgs; [
      cifs-utils
      libva-utils
      nvidia-vaapi-driver
    ];

    environment.variables = {
      # VAAPI and VDPAU config for accelerated video.
      # See https://wiki.archlinux.org/index.php/Hardware_video_acceleration
      "VDPAU_DRIVER" = "nvidia";
      "LIBVA_DRIVER_NAME" = "nvidia";
    };
    # users.users.jellyfin.extraGroups = [
    #   "render"
    #   "video"
    # ];

    sops.secrets =
      {
        "jellyfin/tmdb-api-key_declarr" = {
          key = "jellyfin/tmdb-api-key";
          owner = config.services.declarr.user;
          sopsFile = "${self}/secrets/server.yaml";
        };
        "jellyseerr/api-key_declarr" = {
          key = "jellyseerr/api-key";
          owner = config.services.declarr.user;
          sopsFile = "${self}/secrets/server.yaml";
        };

        "jellyfin/api-key" = {
          owner = config.services.jellyfin.user;
          sopsFile = "${self}/secrets/server.yaml";
        };
        "jellyseerr/api-key_jellyfin" = {
          key = "jellyseerr/api-key";
          owner = config.services.jellyfin.user;
          sopsFile = "${self}/secrets/server.yaml";
        };
      }
      // (lib.pipe config.services.declarative-jellyfin.users [
        lib.attrNames
        (lib.concatMap (u: [
          "jellyfin/users/${u}/password"
          "jellyfin/users/${u}/passwordHash"
        ]))
        (lib.map (s: {
          name = s;
          value = {
            owner = config.services.jellyfin.user;
            sopsFile = "${self}/secrets/server.yaml";
          };
        }))
        lib.listToAttrs
      ]);

    systemd.services.jellyfin.serviceConfig = {
      SupplementaryGroups = [
        # Access to /dev/dri
        "render"
        "video"
        # Access to /raid/media
        "media"
      ];

      # place a literal copy of jellyfin-web
      # this allows for plugins to modify it
      ExecStartPre = lib.mkBefore [
        (pkgs.writeShellScript
          "jellyfin-unpack-web"
          ''
            rm "${jcfg.dataDir}/jellyfin-web/*" -rf
            mkdir "${jcfg.dataDir}/jellyfin-web"
            cp -r \
              ${jcfg.jellyfin-web}/share/jellyfin-web/* \
              "${jcfg.dataDir}/jellyfin-web"
          '')
      ];
    };

    services = {
      declarative-jellyfin = {
        enable = true;
        group = "media";

        package = pkgs.jellyfin.overrideAttrs {
          makeWrapperArgs = [
            "--add-flags"
            "--ffmpeg=${jcfg.jellyfin-ffmpeg}/bin/ffmpeg"
            "--add-flags"
            "--webdir=${jcfg.dataDir}/jellyfin-web"
          ];
          patches = [./remove-size-check.patch];
        };

        system = {
          isStartupWizardCompleted = true;
          trickplayOptions = {
            enableHwAcceleration = true;
            enableHwEncoding = true;
          };
          UICulture = "en";
          # REF: https://github.com/kra3/nix-configs/blob/7936d4527fe5814b2fd7f6afe4329a515b2d2fc6/modules/services/media/players/server/jellyfin.nix#L64
          # REF: https://github.com/matt1432/nixos-configs/blob/005b55fa0e0ae8601c11b557253a041e79fb1729/configurations/nos/modules/jellyfin/jellarr.nix#L166
        };
        network = {
          internalHttpPort = ports.jellyfin;
          publicHttpPort = ports.jellyfin;
        };
        users = lib.mapAttrs (user: v:
          v
          // {
            mutable = false;
            loginAttemptsBeforeLockout = null;
            hashedPasswordFile = config.sops.secrets."jellyfin/users/${user}/passwordHash".path;
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
          # # R
          # guest-17-1.maxParentalRatingSubScore = 17;
          # guest-17-2.maxParentalRatingSubScore = 17;
          # guest-17-3.maxParentalRatingSubScore = 17;
          # guest-17-4.maxParentalRatingSubScore = 17;
          # # PG-13
          # guest-13-1.maxParentalRatingSubScore = 13;
          # guest-13-2.maxParentalRatingSubScore = 13;
          # guest-13-3.maxParentalRatingSubScore = 13;
          # guest-13-4.maxParentalRatingSubScore = 13;
          # # PG
          # guest-10-1.maxParentalRatingSubScore = 10;
          # guest-10-2.maxParentalRatingSubScore = 10;
          # guest-10-3.maxParentalRatingSubScore = 10;
          # guest-10-4.maxParentalRatingSubScore = 10;
          # # G
          # guest-0-1.maxParentalRatingSubScore = 0;
          # guest-0-2.maxParentalRatingSubScore = 0;
          # guest-0-3.maxParentalRatingSubScore = 0;
          # guest-0-4.maxParentalRatingSubScore = 0;
        };

        encoding = {
          enableHardwareEncoding = true;
          hardwareAccelerationType = "nvenc";
          enableDecodingColorDepth10Hevc = true;
          allowHevcEncoding = true;
          # allowAv1Encoding = true;
          hardwareDecodingCodecs = [
            "h264"
            "hevc"
            "mpeg2video"
            "vc1"
            "vp9"
            # "av1" # not supported by my gpu
          ];
        };
        apikeys = {
          Jellyseerr.keyPath = config.sops.secrets."jellyfin/api-key".path;
        };
        branding.customCss = ''
          /* -------------- https://github.com/stpnwf/ZestyTheme -------------- */
          @import url('https://cdn.jsdelivr.net/gh/stpnwf/ZestyTheme@latest/theme.css');

          /* @import url('https://cdn.jsdelivr.net/gh/stpnwf/ZestyTheme@latest/colorschemes/gray.css'); */
          @import url('https://cdn.jsdelivr.net/gh/stpnwf/ZestyTheme@latest/login-alt.css');

          /* fix black backdrop */
          /* https://github.com/stpnwf/ZestyTheme/issues/52 */
          .noBackdropTransparency .detailPagePrimaryContainer,
          .noBackdropTransparency .detailPageSecondaryContainer {
              background-color: transparent;
          }

          /* Revert "Next Up" section back to standard native layout flow */
          .layout-desktop .nextUpSection {
              position: relative !important;
              left: auto !important;
              right: auto !important;
              top: auto !important;
              margin: 2em 0 1em 0 !important;
              /* Restores default top/bottom spacing */
              padding: 0 !important;
              background-color: transparent !important;
              backdrop-filter: none !important;
              border-radius: 0 !important;
              width: auto !important;
              max-width: none !important;
          }

          /* Reset individual Next Up card offsets */
          .layout-desktop .nextUpSection .card.overflowBackdropCard.card-hoverable.card-withuserdata {
              right: auto !important;
              position: relative !important;
          }

          .layout-desktop .nextUpSection .cardBox-bottompadded {
              margin-bottom: 1.5em !important;
          }

          .jellyseerr-media-badge {
              display: none !important;
          }

          /* remove the glow on the ep number on cards */
          .countIndicator,
          .playedIndicator {
              box-shadow: none !important;
              filter: none !important;
              text-shadow: none !important;
          }
        '';
      };

      declarr.config.jellyfin = {
        declarr = {
          type = "jellyfin";
          url = "https://jellyfin.upidapi.dev";
          apiKey = config.sops.secrets."jellyfin/api-key_declarr".path;
          resolvePaths = [
            ''$.plugins.["Jellyfin Enhanced"].TMDB_API_KEY''
            ''$.plugins.["Jellyfin Enhanced"].JellyseerrApiKey''
          ];
        };

        libraries = {
          "Movies" = {
            enabled = true;
            collectionType = "movies";
            paths = ["/raid/media/movies"];
            libraryOptions = {
              enableChapterImageExtraction = true;
              extractChapterImagesDuringLibraryScan = true;
              enableTrickplayImageExtraction = true;
              extractTrickplayImagesDuringLibraryScan = true;
              saveTrickplayWithMedia = true;
            };
          };
          "Shows" = {
            enabled = true;
            collectionType = "tvshows";
            paths = ["/raid/media/tv"];
            libraryOptions = {
              enableChapterImageExtraction = true;
              extractChapterImagesDuringLibraryScan = true;
              enableTrickplayImageExtraction = true;
              extractTrickplayImagesDuringLibraryScan = true;
              saveTrickplayWithMedia = true;
            };
          };
        };

        pluginRepositories = {
          "Jellyfin Stable".url = "https://repo.jellyfin.org/releases/plugin/manifest-stable.json";
          "Intro Skipper".url = "https://manifest.intro-skipper.org/manifest.json";
          "Merge Versions Plugin".url = "https://raw.githubusercontent.com/danieladov/JellyfinPluginManifest/master/manifest.json";
          "Meilisearch".url = "https://raw.githubusercontent.com/arnesacnussem/jellyfin-plugin-meilisearch/refs/heads/master/manifest.json";
          "Air Times".url = "https://raw.githubusercontent.com/apteryxxyz/jellyfin-plugin-airtimes/main/manifest.json";
          "InPlayerEpisodePreview".url = "https://raw.githubusercontent.com/Namo2/InPlayerEpisodePreview/master/manifest.json";
          "Streamyfin".url = "https://raw.githubusercontent.com/streamyfin/jellyfin-plugin-streamyfin/main/manifest.json";
          "Editor's Choice".url = "https://github.com/lachlandcp/jellyfin-editors-choice-plugin/raw/main/manifest.json";
          "Jellyfin Enhanced".url = "https://raw.githubusercontent.com/n00bcodr/jellyfin-plugins/main/10.11/manifest.json";
          "File Transformation".url = "https://www.iamparadox.dev/jellyfin/plugins/manifest.json";
        };
        plugins = {
          # there is also https://gitlab.com/DomiStyle/jellysearch
          # but that requires setting up a rev proxy that captures trafic
          # this seams just better atm

          # Disabled since it breaks seerr search
          # "Meilisearch" = {
          #   ApiKey = "";
          #   Url = "http://127.0.0.1:${toString ports.meilisearch}";
          #   Debug = false;
          #   IndexName = "";
          #   MatchingStrategy = "last";
          # };

          "Studio Images" = {
            RepositoryUrl = "https://raw.githubusercontent.com/jellyfin/emby-artwork/master/studios";
          };
          "MusicBrainz" = {
            Server = "https://musicbrainz.org";
            RateLimit = 1;
            ReplaceArtistName = false;
          };

          "Media Bar" = {
            WebConfig.EnableTrailers = false;
          };
          "File Transformation" = {
            DebugLoggingState = "Disabled";
          };
          "Plugin Pages" = {};

          "Jellyfin Enhanced" = {
            TMDB_API_KEY = config.sops.secrets."jellyfin/tmdb-api-key_declarr".path;

            ElsewhereEnabled = false;
            ShowReviews = false;

            # ClearTranslationCacheTimestamp = 1779659439045;
            AutoSkipIntro = true;
            AutoSkipOutro = true;

            JellyseerrEnabled = true;
            JellyseerrUrls = "https://seerr.upidapi.dev";
            JellyseerrApiKey = config.sops.secrets."jellyseerr/api-key_declarr".path;

            AutoSeasonRequestEnabled = true;
            AutoMovieRequestEnabled = true;

            DownloadsPageEnabled = true;
          };

          "AudioDB".ReplaceAlbumName = false;
          "Air Times" = {};
          "Intro Skipper" = {
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
          "Merge Versions" = {};
          "Streamyfin" = {
            settings = {
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
                locked = false;
                value = "https://seerr.upidapi.dev";
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

          "OMDb" = {
            CastAndCrew = false;
          };
          "TheTVDB" = {};
          "TMDb" = {
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

          "JavaScript Injector".CustomJavaScripts = [
            {
              Name = "Add discover button";

              Script = ''
                (function() {
                    'use strict';

                    const targetUrl = 'https://seerr.upidapi.dev';
                    const targetTextLower = 'favorites';
                    const newText = 'Discover';

                    function replaceTextInNode(node, fromText, toText) {
                        if (node.nodeType === Node.TEXT_NODE) {
                            if (node.textContent.trim().toLowerCase() === fromText.toLowerCase()) {
                                node.textContent = toText;
                            }
                        } else {
                            for (let child of node.childNodes) {
                                replaceTextInNode(child, fromText, toText);
                            }
                        }
                    }

                    function modifyFavoritesElements() {
                        const selectors = 'a, button, .emby-tab-button, .navMenuOption, .lnkMediaFolder';
                        const elements = document.querySelectorAll(selectors);

                        elements.forEach(el => {
                            const text = el.textContent ? el.textContent.trim() : "";

                            if (text.toLowerCase() === targetTextLower && !el.dataset.discoverModified) {
                                // Mark as modified to avoid registering duplicate event listeners
                                el.dataset.discoverModified = 'true';

                                // Safely update the text label
                                replaceTextInNode(el, targetTextLower, newText);

                                // Intercept the click event to open in a new tab
                                el.addEventListener('click', function(e) {
                                    e.preventDefault();
                                    e.stopPropagation();
                                    window.open(targetUrl, '_blank'); 
                                }, true); // "true" uses the capture phase to override the app's default router

                                // Update anchor tag attributes if applicable
                                if (el.tagName === 'A') {
                                    el.setAttribute('href', targetUrl);
                                    el.setAttribute('target', '_blank');
                                    el.setAttribute('rel', 'noopener noreferrer');
                                }
                            }
                        });
                    }

                    // Set up a MutationObserver to handle dynamic page loads and navigation
                    const observer = new MutationObserver(() => {
                        modifyFavoritesElements();
                    });

                    observer.observe(document.body, {
                        childList: true,
                        subtree: true
                    });

                    // Run once on load
                    modifyFavoritesElements();
                })();
              '';
            }
          ];
          # REF: https://github.com/IAmParadox27/jellyfin-plugin-custom-tabs
          # REF: https://github.com/IAmParadox27/jellyfin-plugin-home-sections#ive-installed-the-plugins-and-dont-get-any-options-or-changes-how-do-i-fix
          # "Custom Tabs".Tabs = [
          #   {
          #     Title = "Request";
          #     ContentHtml = ''
          #       <style>
          #       .requestPageFix,
          #       .requestPageFix * {
          #         margin: 0 !important;
          #         padding: 0 !important;
          #         box-sizing: border-box !important;
          #       }
          #
          #       .requestPageFix {
          #         position: fixed !important;
          #         top: 80px !important;
          #         left: 0 !important;
          #         width: 100vw !important;
          #         height: calc(100vh - 80px) !important;
          #         overflow: hidden !important;
          #         z-index: 10 !important;
          #         background: transparent !important;
          #       }
          #
          #       .requestIframe {
          #         width: 100% !important;
          #         height: 100% !important;
          #         border: 0 !important;
          #         background: transparent !important;
          #         display: block !important;
          #       }
          #
          #       /* Desktop */
          #       @media (min-width: 1000px) {
          #         .requestPageFix {
          #           top: 80px !important;
          #           height: calc(100vh - 80px) !important;
          #         }
          #       }
          #
          #       /* Tablet: header + tabs */
          #       @media (min-width: 600px) and (max-width: 999px) {
          #         .requestPageFix {
          #           top: 150px !important;
          #           height: calc(100vh - 150px) !important;
          #         }
          #       }
          #
          #       /* Mobile: header + tabs */
          #       @media (max-width: 599px) {
          #         .requestPageFix {
          #           top: 145px !important;
          #           height: calc(100vh - 145px) !important;
          #         }
          #       }
          #
          #       .skinHeader {
          #         z-index: 1000 !important;
          #       }
          #
          #       .skinHeader::after {
          #         pointer-events: none !important;
          #       }
          #       </style>
          #
          #       <div class="requestPageFix">
          #         <iframe
          #           class="requestIframe"
          #           src="https://seerr.upidapi.dev">
          #         </iframe>
          #       </div>
          #     '';
          #   }
          # ];
        };
      };
    };
  };
}
