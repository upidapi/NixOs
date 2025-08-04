{
  config,
  lib,
  mlib,
  self',
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.apps.discord;
in {
  options.modules.home.apps.discord =
    mkEnableOpt "Whether or not to enable discord."
    // {
      package = mkOption {
        type = types.package;
        default = self'.packages.vesktop.override {withSystemVencord = false;};
      };

      finalPackage = mkOption {
        type = types.package;
        readOnly = true;
        default = cfg.package.overrideAttrs {
          postFixup = ''
            wrapProgram $out/bin/${lib.getName cfg.package} \
              --add-flags "--enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland"
          '';
        };
      };
    };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    stylix.targets.vesktop.enable = false;

    xdg.configFile = {
      "vesktop/settings/settings.json".text = builtins.toJSON (
        (builtins.fromJSON (builtins.readFile ./vencord-config.json))
        // {
          notifyAboutUpdates = true;
          autoUpdate = false;
          autoUpdateNotification = true;
          useQuickCss = true;
          themeLinks = [
            # halfbroken tokyo night theme
            # "https://raw.githubusercontent.com/Dyzean/Tokyo-Night/main/themes/tokyo-night.theme.css"
          ];
          enabledThemes = [
            # custom theme
            "theme.css"
          ];
          enableReactDevtools = false;
          frameless = false;
          transparent = false;
          winCtrlQ = false;
          disableMinSize = false;
          winNativeTitleBar = false;
        }
      );

      "vesktop/themes/theme.css".text = builtins.readFile ./theme.css;

      "vesktop/settings.json".text = builtins.toJSON {
        arRPC = "on";
        discordBranch = "stable";
        hardwareAcceleration = false;
        minimizeToTray = "on";

        splashTheming = true;
        splashColor = config.stylix.base16Scheme.base07;
        splashBackground = config.stylix.base16Scheme.base01;

        tray = true;
        trayBadge = true;
      };
    };

    # vesktop schecks if state.json has the "firstLaunch" to
    # determine if it should show the "Welcome to vesktop" page
    home.activation = {
      # We have to do it like this since vesktop needs be able to
      # write to it (a symlink to the store would have been unwritabe)
      # If vesktop can't write to it then it chrashes
      createVesktiopStateJson = let
        state_path = "~/.config/vesktop/state.json";
        data = builtins.toJSON {
          # (the other setting dont matter)
          firstLaunch = false; # the value of this is ignored lol
        };
      in
        lib.hm.dag.entryAfter ["linkGeneration"] ''
          echo '${data}' > ${state_path}
        '';
    };
  };
}
/*
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.customPrograms.discord;
  inherit (lib) mkEnableOption mkOption mkIf types;
in {
  options.customPrograms.discord = {
    enable = mkEnableOption "";

    package = mkOption {
      type = types.package;
      default = pkgs.vesktop;
    };

    finalPackage = mkOption {
      type = types.package;
      readOnly = true;
      default = cfg.package.overrideAttrs {
        postFixup = ''
          wrapProgram $out/bin/${lib.getName cfg.package} \
            --add-flags "--enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland"
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile = {
      "vesktop/settings/settings.json".text = builtins.toJSON {
        autoUpdate = false;
        autoUpdateNotification = true;
        disableMinSize = false;
        enableReactDevtools = false;
        enabledThemes = [];
        frameless = false;
        macosTranslucency = false;
        notifications = {
          logLimit = 50;
          position = "bottom-right";
          timeout = 5000;
          useNative = "not-focused";
        };
        notifyAboutUpdates = true;

        plugins = {

        };
        themeLinks = [
          "https://raw.githubusercontent.com/orblazer/discord-nordic/master/nordic.vencord.css"
        ];
        transparent = false;
        useQuickCss = false;
        winCtrlQ = false;
        winNativeTitleBar = false;
      };

      "vesktop/settings.json".text = builtins.toJSON {
        arRPC = "on";
        discordBranch = "stable";
        hardwareAcceleration = false;
        minimizeToTray = "on";
        splashBackground = "rgb(59, 66, 82)";
        splashColor = "rgb(216, 222, 233)";
        splashTheming = true;
        tray = true;
        trayBadge = true;
      };
    };

    home.packages = [cfg.finalPackage];
  };
}
*/
/*
{
  config,
  lib,
  mlib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.apps.discord;
in {
  options.modules.home.apps.discord =
    mkEnableOpt "Whether or not to enable discord.";

  config.home = mkIf cfg.enable {
    packages = [
      (pkgs.discord-canary.override {
        withOpenASAR = true;
        withVencord = true;
      })
      pkgs.vesktop # for screen sharing on wayland
    ];
    # tested (diddn't work)

    # disabling hardware acseleartion
    # --no-gpu
    # --enable-features=UseOzonePlatform --ozone-platform=wayland

    file."${config.xdg.configHome}/Vencord/settings/settings.json" = {
      force = true;
      text = builtins.readFile ./vencord-config.json;
    };
  };
}
*/
# you need to use --disable-gpu for discord to work
/*
   {
  config,
  lib,
  mlib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.apps.discord;
in {
  options.modules.home.apps.discord =
    mkEnableOpt "Whether or not to enable discord.";

  config.home = mkIf cfg.enable {
    packages = [
      (pkgs.discord-canary.override {
        # remove any overrides that you don't want
        # withOpenASAR = true;
        # withVencord = true;
      })
      # pkgs.vesktop # for screen sharing on wayland
    ];

    # file."${config.xdg.configHome}/Vencord/settings/settings.json" = {
    #   force = true;
    #   text = builtins.readFile ./vencord-config.json;
    # };
  };
}
*/
/*
   {
  config,
  lib,
  pkgs,
  mlib,
  ...
}: let
  cfg = config.modules.home.apps.discord;
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
in {
  options.modules.home.apps.discord = mkEnableOpt "";

  config = mkIf cfg.enable {
    home = {
      packages = [
        (pkgs.discord-canary.override {
          withOpenASAR = true;
          withVencord = true;
        })
      ];

      file."${config.xdg.configHome}/Vencord/settings/settings.json" = {
        force = true;
        text = builtins.toJSON {
          notifyAboutUpdates = true;
          autoUpdate = false;
          autoUpdateNotification = true;
          useQuickCss = false;
          themeLinks = [
            "https://raw.githubusercontent.com/orblazer/discord-nordic/master/nordic.vencord.css"
          ];
          enableReactDevtools = false;
          frameless = false;
          transparent = false;
          winCtrlQ = false;
          macosTranslucency = false;
          disableMinSize = false;
          winNativeTitleBar = false;
          plugins = {
            BadgeAPI.enabled = true;
            CommandsAPI.enabled = true;
            ContextMenuAPI.enabled = true;
            MemberListDecoratorsAPI.enabled = true;
            MessageAccessoriesAPI.enabled = true;
            MessageDecorationsAPI.enabled = true;
            MessageEventsAPI.enabled = true;
            MessagePopoverAPI.enabled = true;
            NoticesAPI.enabled = true;
            SettingsStoreAPI.enabled = true;
            NoTrack.enabled = true;
            Settings = {
              enabled = true;
              settingsLocation = "aboveActivity";
            };
            AnonymiseFileNames = {
              enabled = false;
              method = 0;
              randomisedLength = 10;
              consistent = "image";
            };
            BetterFolders = {
              enabled = true;
              sidebar = true;
              sidebarAnim = true;
              closeAllFolders = false;
              closeAllHomeButton = false;
              closeOthers = false;
              forceOpen = false;
              showFolderIcon = 1;
              keepIcons = false;
            };
            BetterNotesBox = {
              enabled = true;
              hide = false;
              noSpellCheck = true;
            };
            BiggerStreamPreview.enabled = true;
            CallTimer = {
              enabled = true;
              format = "human";
            };
            CrashHandler = {
              enabled = true;
              attemptToPreventCrashes = true;
              attemptToNavigateToHome = false;
            };
            EmoteCloner.enabled = true;
            Experiments = {
              enabled = true;
              enableIsStaff = false;
              forceStagingBanner = false;
            };
            FakeNitro = {
              enabled = true;
              enableEmojiBypass = true;
              emojiSize = 48;
              transformEmojis = true;
              enableStickerBypass = true;
              stickerSize = 160;
              transformStickers = true;
              transformCompoundSentence = false;
              enableStreamQualityBypass = true;
            };
            FavoriteEmojiFirst.enabled = true;
            ForceOwnerCrown.enabled = true;
            GifPaste.enabled = true;
            ImageZoom = {
              enabled = true;
              saveZoomValues = true;
              preventCarouselFromClosingOnClick = true;
              invertScroll = true;
              nearestNeighbour = false;
              square = false;
              zoom = 2.0;
              size = 792;
              zoomSpeed = 0.5;
            };
            KeepCurrentChannel.enabled = true;
            LoadingQuotes = {
              enabled = true;
              replaceEvents = true;
            };
            MemberCount.enabled = true;
            MessageLinkEmbeds = {
              enabled = true;
              automodEmbeds = "never";
              listMode = "blacklist";
              idList = "";
            };
            MessageLogger = {
              enabled = true;
              deleteStyle = "overlay";
              ignoreBots = false;
              ignoreSelf = false;
              ignoreUsers = "";
              ignoreChannels = "";
              ignoreGuilds = "";
            };
            MoreUserTags = {
              enabled = true;
              tagSettings = {
                WEBHOOK = {
                  text = "Webhook";
                  showInChat = true;
                  showInNotChat = true;
                };
                OWNER = {
                  text = "Owner";
                  showInChat = true;
                  showInNotChat = true;
                };
                ADMINISTRATOR = {
                  text = "Admin";
                  showInChat = true;
                  showInNotChat = true;
                };
                "MODERATOR_STAFF" = {
                  text = "Staff";
                  showInChat = false;
                  showInNotChat = false;
                };
                MODERATOR = {
                  text = "Mod";
                  showInChat = true;
                  showInNotChat = true;
                };
                "VOICE_MODERATOR" = {
                  text = "VC Mod";
                  showInChat = false;
                  showInNotChat = true;
                };
              };
            };
            MutualGroupDMs.enabled = true;
            NoF1.enabled = true;
            NoReplyMention = {
              enabled = true;
              userList = "372809091208445953";
              shouldPingListed = false;
              inverseShiftReply = false;
            };
            NoTypingAnimation.enabled = true;
            PermissionsViewer = {
              enabled = true;
              permissionsSortOrder = 0;
              defaultPermissionsDropdownState = false;
            };
            PlatformIndicators = {
              enabled = true;
              list = true;
              badges = true;
              messages = false;
              colorMobileIndicator = true;
            };
            RelationshipNotifier = {
              enabled = true;
              notices = true;
              offlineRemovals = true;
              friends = true;
              friendRequestCancels = true;
              servers = true;
              groups = true;
            };
            SearchReply.enabled = true;
            SendTimestamps.enabled = true;
            ShikiCodeblocks = {
              enabled = true;
              useDevIcon = "GREYSCALE";
              theme = "https://raw.githubusercontent.com/shikijs/shiki/0b28ad8ccfbf2615f2d9d38ea8255416b8ac3043/packages/shiki/themes/github-dark-dimmed.json";
              tryHljs = "SECONDARY";
              bgOpacity = 100;
            };
            ShowHiddenChannels = {
              enabled = true;
              hideUnreads = true;
              showMode = 1;
              defaultAllowedUsersAndRolesDropdownState = true;
            };
            ShowTimeouts.enabled = true;
            SilentTyping = {
              enabled = true;
              showIcon = false;
              isEnabled = true;
            };
            SortFriendRequests = {
              enabled = true;
              showDates = false;
            };
            SupportHelper.enabled = true;
            Translate = {
              enabled = true;
              autoTranslate = false;
              receivedInput = "auto";
              receivedOutput = "en";
              sentInput = "auto";
              sentOutput = "en";
            };
            TypingIndicator = {
              enabled = true;
              includeMutedChannels = true;
              includeBlockedUsers = false;
            };
            TypingTweaks = {
              enabled = true;
              showAvatars = true;
              showRoleColors = true;
              alternativeFormatting = true;
            };
            UserVoiceShow = {
              enabled = true;
              showInUserProfileModal = true;
              showVoiceChannelSectionHeader = true;
            };
            UwUifier = {
              enabled = true;
              uwuEveryMessage = false;
            };
            ValidUser.enabled = true;
            ViewIcons = {
              enabled = true;
              format = "png";
              imgSize = "4096";
            };
            ViewRaw = {
              enabled = true;
              clickMethod = "Left";
            };
            WhoReacted.enabled = true;
          };
          notifications = {
            timeout = 5000;
            position = "bottom-right";
            useNative = "not-focused";
            logLimit = 50;
          };
          cloud = {
            authenticated = false;
            url = "https://api.vencord.dev/";
            settingsSync = false;
            settingsSyncVersion = 1704773064108;
          };
          enabledThemes = [];
        };
      };
    };
  };
}
*/

