{
  config,
  inputs,
  pkgs,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf stringToCharacters;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.apps.firefox;

  firefox-pkgs = inputs.firefox-addons.packages.${pkgs.system};
in {
  options.modules.home.apps.firefox =
    mkEnableOpt "enables firefox";

  imports = [inputs.zen-browser.homeModules.beta];

  # https://addons.mozilla.org/en-US/firefox/addon/netflux/
  # https://itsfoss.com/netflix-full-hd-firefox/

  # https://itsfoss.com/firefox-add-ons/

  # since hyprland opens all windows in fullscreen, firefox thinks it is and
  # therefore sets it to fullscreen when reopening old windows. The windows

  # https://github.com/qutebrowser/qutebrowser a vim like browser with minimal
  # gui and a focus on the keyboard

  # prevent firefox from opening in fullscreen when you restore with ctrl shift
  # t

  # switch to zen browser? not until they add horizontal tabs could use
  # https://github.com/mmmintdesign/Zen-Mod-Forbidden-Horizontal-Tabs
  #
  #  can be run thrugh this flake
  #  https://github.com/0xc000022070/zen-browser-flake
  #
  #  good config
  #  https://github.com/SergioRibera/dotfiles/blob/main/home/desktop/browser/zen/default.nix

  # possibly might disable the restore screen
  # browser.sessionstore.resume_from_crash

  # setting "full-screen-api.ignore-widgets" to true allows for
  # psudo-fullscreen where it doesn't actually full screen it
  # https://superuser.com/a/1742237

  # tampermonkey and stylus can be a good source for user scripts

  # https://www.reddit.com/r/firefox/comments/17hlkhp/what_are_your_must_have_changes_in_aboutconfig/

  config = mkIf cfg.enable {
    # Zen todos
    # Better keybinds
    # https://github.com/zen-browser/desktop/pull/9441

    # Figure out (wait for them to implement) how to export/import settings

    programs.zen-browser = {
      enable = true;
      policies = config.programs.firefox.policies;
      profiles =
        lib.mapAttrs (_: v: {
          inherit (v) id name extensions settings;
          search = {
            inherit (v.search) force default engines;
          };
        })
        config.programs.firefox.profiles;
    };

    home.file.".local/share/applications/zen-base.desktop".text = ''
      [Desktop Entry]
      Categories=Network;WebBrowser
      Exec=zen --name "zen base" -P "base" %U
      GenericName=Web Browser
      Icon=zen
      Name=Zen Base
      StartupNotify=true
      StartupWMClass=zen
      Terminal=false
      Type=Application
    '';

    home.file.".local/share/applications/firefox-base.desktop".text = ''
      [Desktop Entry]
      Categories=Network;WebBrowser
      Exec=firefox --name "firefox base" -P "base" %U
      GenericName=Web Browser
      Icon=firefox
      Name=Firefox Base
      StartupNotify=true
      StartupWMClass=firefox
      Terminal=false
      Type=Application
    '';

    programs.firefox = rec {
      enable = true;
      policies = {
        CaptivePortal = false;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisableFirefoxAccounts = false;
        # Disable the Refresh Firefox button on about:support and
        # support.mozilla.org
        DisableProfileRefresh = true;
        # Remove the “Set As Desktop Background…” menuitem when right
        # clicking on an image, because Nix is the only thing that can manage
        # the backgroud
        DisableSetDesktopBackground = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        OfferToSaveLoginsDefault = false;
        PasswordManagerEnabled = false;
        FirefoxHome = {
          Search = true;
          Pocket = false;
          Snippets = false;
          TopSites = false;
          Highlights = false;
        };
        UserMessaging = {
          ExtensionRecommendations = false;
          SkipOnboarding = true;
        };
        Preferences = {
          # zen locks this :) (its ads)
          # https://github.com/zen-browser/desktop/blob/df1e759c8d36bba2052a9514e03702d9432efdbc/prefs/urlbar.yaml#L59
          # also breaks the empty url bar
          # "browser.urlbar.suggest.topsites" = false;
        };
      };
      profiles = {
        "${config.home.username}" = let
          colors = config.lib.stylix.colors.withHashtag;
          mappedCssColors = builtins.concatStringsSep "\n" (
            builtins.map
            (x: "  --base0${x}: ${colors."base0${x}"};")
            (stringToCharacters "0123456789ABCDEF")
          );
          cssColors =
            ''
              :root {
              ${mappedCssColors}
              }''
            + "\n";
        in {
          id = 0;
          name = config.home.username;

          /*
          for editing the broswer html

          https://www.dedoimedo.com/computers/firefox-change-ui-tutorial.html

          # pref:
          devtools.chrome.enabled
          devtools.debugger.remote-enabled
          */
          # Custom CSS style options

          userChrome = cssColors + builtins.readFile ./userChrome.css;
          userContent = cssColors + builtins.readFile ./userContent.css;

          search = {
            force = true;
            default = "ddg";
            engines = let
              mkGithubSearch = alias: params: {
                urls = [
                  {
                    template = "https://github.com/search";
                    params = [
                      {
                        name = "q";
                        value = "${params} {searchTerms}";
                      }
                      {
                        name = "type";
                        value = "code";
                      }
                    ];
                  }
                ];
                definedAliases = alias;
                icon = "${pkgs.nordzy-icon-theme}/share/icons/Nordzy/places/16/folder-github.svg";
              };
            in {
              "noogle" = {
                definedAliases = ["@ng" "@noogle"];
                urls = [
                  {
                    template = "https://noogle.dev/q";
                    params = [
                      {
                        name = "term";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              };

              "Youtube" = {
                definedAliases = ["@y"];
                urls = [
                  {
                    template = "https://www.youtube.com/results";
                    params = [
                      {
                        name = "search_query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
              };

              "Google Images" = {
                definedAliases = ["@gi"];
                urls = [
                  {
                    template = "https://www.google.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
              };

              "Nix Packages" = {
                definedAliases = ["@np" "@nixpkgs"];
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "type";
                        value = "packages";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              };
              "NixOS Wiki" = {
                definedAliases = ["@nw" "@nixwiki"];
                urls = [{template = "https://wiki.nixos.org/w/index.php?search={searchTerms}";}];
                icon = "https://wiki.nixos.org/favicon.ico";
                updateInterval = 24 * 60 * 60 * 1000;
              };

              "Github" = mkGithubSearch ["@g" "@gh" "@github"] "";

              "Github Nix Code" = mkGithubSearch ["@gn" "ghnix"] "lang:nix";

              "Github Nixpkgs" =
                mkGithubSearch ["@gnp" "@ghnixpkgs"]
                "repo:NixOS/nixpkgs lang:nix";

              "Github Home Manager" =
                mkGithubSearch ["@ghm" "@ghhomemanager"]
                "repo:nix-community/home-manager lang:nix";

              # "Wikipedia (en)".metaData.alias = "@wiki";
              "google".metaData.hidden = true;
              "amazondotcom-us".metaData.hidden = true;
              "bing".metaData.hidden = true;
              "ebay".metaData.hidden = true;
            };
          };
          extensions = {
            packages = with firefox-pkgs; [
              # bitwarden

              # floccus  # syncs bookmarks
              # languagetool

              # vim binds for the browser
              vimium

              react-devtools

              # un clickbait youtube
              # dearrow
              sponsorblock
              return-youtube-dislikes

              # qol
              refined-github
              i-dont-care-about-cookies
              darkreader

              # all you can do with this can be exported and placed in userContent.css
              # so it's used to quickly iterate before placing it in there
              # since you cant config extensions declaratively
              stylus

              # privacy
              # https-everywhere  # not on system
              user-agent-string-switcher
              ublock-origin
              clearurls
              decentraleyes # local cdn
              # privacy-redirect

              # unnecessary with ubo
              # duckduckgo-privacy-essentials
              # disconnect
              # ghostery
              # privacy-badger

              buster-captcha-solver
            ];
            # settings = with firefox-pkgs; {
            #   "${ublock-origin.addonId}".settings = {};
            # };
          };

          settings = {
            # FROM: https://github.com/TLATER/dotfiles/blob/main/home-config/config/graphical-applications/firefox.nix
            "general.smoothScroll" = true;

            # Performance settings
            # "gfx.webrender.all" = true; # Force enable GPU acceleration
            "media.ffmpeg.vaapi.enabled" = true;
            "widget.dmabuf.force-enabled" = true; # Required in recent Firefoxes

            # Re-bind ctrl to super (would interfere with tridactyl otherwise)
            # "ui.key.accelKey" = 91;

            # Keep the reader button enabled at all times; really don't
            # care if it doesn't work 20% of the time, most websites are
            # crap and unreadable without this
            "reader.parse-on-load.force-enabled" = true;

            # Hide the "sharing indicator", it's especially annoying
            # with tiling WMs on wayland
            "privacy.webrtc.legacyGlobalIndicator" = false;

            # Actual settings
            "app.shield.optoutstudies.enabled" = false;
            "app.update.auto" = false;
            "browser.bookmarks.restore_default_bookmarks" = false;
            "browser.contentblocking.category" = "strict";
            "browser.ctrlTab.recentlyUsedOrder" = false;
            "browser.discovery.enabled" = false;
            "browser.laterrun.enabled" = false;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" =
              false;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" =
              false;
            "browser.newtabpage.activity-stream.feeds.snippets" = false;
            "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.havePinned" = "";
            "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.searchEngines" = "";
            "browser.newtabpage.activity-stream.section.highlights.includePocket" =
              false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            # "browser.newtabpage.pinned" = false;
            "browser.protections_panel.infoMessage.seen" = true;
            "browser.quitShortcut.disabled" = true;
            "browser.shell.checkDefaultBrowser" = false;
            "browser.ssb.enabled" = true;
            "browser.toolbars.bookmarks.visibility" = "never";
            "browser.urlbar.placeholderName" = "DuckDuckGo";
            "browser.urlbar.suggest.openpage" = false;
            "datareporting.policy.dataSubmissionEnable" = false;
            "datareporting.policy.dataSubmissionPolicyAcceptedVersion" = 2;
            "dom.security.https_only_mode" = true;
            "dom.security.https_only_mode_ever_enabled" = true;
            "extensions.getAddons.showPane" = false;
            "extensions.htmlaboutaddons.recommendations.enabled" = false;
            "identity.fxaccounts.enabled" = false;
            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.socialtracking.enabled" = true;

            # ---------- the following is my custom ---------
            "browser.search.suggest.enabled" = true;
            "browser.urlbar.suggest.searches" = true;
            "browser.urlbar.suggest.recentsearches" = true;

            # disable sponsored websites in search (zen)
            # https://github.com/zen-browser/desktop/discussions/8380#discussioncomment-13228893
            # breaks the empty hover search
            "browser.newtabpage.activity-stream.feeds.system.topsites" = false;
            "browser.newtabpage.activity-stream.feeds.system.topstories" = false;

            "zen.view.compact.enable-at-startup" = true;

            # Make it so that "open location" (ctrl + L) always opens the
            # current url instead of persisting if edit
            # https://github.com/zen-browser/desktop/issues/7667
            # partially fixed by
            "zen.urlbar.wait-to-clear" = 0;

            # disable the "is now full-screen" thingy
            "full-screen-api.warning.timeout" = 0;

            # just a test, makes the extensions use json to store their data
            # instead of a sql db
            "extensions.webextensions.ExtensionStorageIDB.enabled" = false;

            # enable extensions by default
            # https://support.mozilla.org/en-US/questions/1219401
            "extensions.autoDisableScopes" = 0;

            "middlemouse.paste" = false;

            "browser.aboutConfig.showWarning" = false;

            # disable the allow paste pop upp
            "devtools.selfxss.count" = 5;

            # anything smaller doesn't do anything
            "browser.tabs.tabMinWidth" = 22;

            # 0 auto, 1 light, 2 dark
            "blayout.css.prefers-color-scheme.content-override" = 2;

            # enable the userChrome
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

            "browser.newtabpage.activity-stream.feeds.topsites" = true;
            "browser.newtabpage.pinned" = [
              {url = "https://www.youtube.com/";}
              {url = "https://github.com/";}
              {url = "https://noogle.dev/";}
              {url = "https://www.netflix.com/browse";}
              {url = "https://www.samskolan.se/login/";}
            ];
          };

          # firefox hardening
          # https://github.com/arkenfox/user.js/blob/master/user.js

          /*
            user_pref("full-screen-api.ignore-widgets", true);
            user_pref("media.ffmpeg.vaapi.enabled", true);
            user_pref("media.rdd-vpx.enabled", true);
          '';
          */
        };

        test =
          profiles."${config.home.username}"
          // {
            id = 1;
            name = "test";
          };

        # For security testing and other stuff where you need a
        # profile where I can guarantee that i haven't fucked anything
        # upp (all behaviors are the default ones)
        base = {
          id = 2;
          name = "base";
        };
      };
    };
  };
}
