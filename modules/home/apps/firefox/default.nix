{
  config,
  inputs,
  pkgs,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.apps.firefox;
in {
  options.modules.home.apps.firefox =
    mkEnableOpt
    "enables firefox";

  # TODO: add better keybinds
  #  probably those vim keybinds
  #  and that mode whereeach link gets it's own two
  #  char code to click.
  #  important
  #    duplicate
  #    close other
  #    close all but open new

  # TODO: fix teams
  # TODO: rearrow (community thumbnails for youtube)
  # TODO: add https://github.com/ray-lothian/UserAgent-Switcher

  # add to sytlus to fix netflix spoilters
  /*
  @-moz-document domain("www.netflix.com") {
    span.duration:not(:hover), div.titleCard-title_index:not(:hover)  {
        color: rgb(0, 0, 0);
        background-color: rgb(0, 0, 0);
    }
  }
  */

  # https://www.reddit.com/r/imdb/comments/109gc27/is_there_any_working_method_to_hide_the_episodes/

  # possibly might disable the restore screen
  # browser.sessionstore.resume_from_crash
  config = mkIf cfg.enable {
    home.sessionVariables = {
      BROWSER = "firefox";
    };

    programs.firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        extraPolicies = {
          CaptivePortal = false;
          DisableFirefoxStudies = true;
          DisablePocket = false; # change to true
          DisableTelemetry = true;
          DisableFirefoxAccounts = false;
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
        };
      };
      profiles = rec {
        upidapi = {
          id = 0;
          name = config.home.username;
          search = {
            force = true;
            default = "DuckDuckGo";
            engines = {
              /*
                 "Nix Packages" = {
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
                definedAliases = ["@np"];
              };
              "NixOS Wiki" = {
                urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
                iconUpdateURL = "https://nixos.wiki/favicon.png";
                updateInterval = 24 * 60 * 60 * 1000;
                definedAliases = ["@nw"];
              };
              */
              # "Wikipedia (en)".metaData.alias = "@wiki";
              "Google".metaData.hidden = true;
              "Amazon.com".metaData.hidden = true;
              "Bing".metaData.hidden = true;
              "eBay".metaData.hidden = true;
            };
          };
          extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
            # bitwarden  # security problem

            # floccus  # syncs bookmarks
            # languagetool

            ublock-origin

            react-devtools

            i-dont-care-about-cookies

            darkreader

            stylus # the config is in stylus.json

            # privacy
            # https-everywhere  # not on system
            clearurls
            disconnect
            decentraleyes
            duckduckgo-privacy-essentials
            # ghostery
            # privacy-badger
            # privacy-redirect

            buster-captcha-solver

            sponsorblock
            return-youtube-dislikes
          ];

          settings = {
            # "barrowed" from https://github.com/TLATER/dotfiles/blob/b39af91fbd13d338559a05d69f56c5a97f8c905d/home-config/config/graphical-applications/firefox.nix
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
            # "extensions.pocket.enabled" = false;
            "identity.fxaccounts.enabled" = false;
            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.socialtracking.enabled" = true;

            # ---------- the following is my custom ---------
            # enable extensions by default
            # https://support.mozilla.org/en-US/questions/1219401
            "extensions.autoDisableScopes" = 0;

            "browser.aboutConfig.showWarning" = false;

            # anything smaller doesn't do anything
            "browser.tabs.tabMinWidth" = 22;

            # 0 auto, 1 light, 2 dark
            "blayout.css.prefers-color-scheme.content-override" = 2;

            "browser.newtabpage.activity-stream.feeds.topsites" = true;
            "browser.newtabpage.pinned" = [
              {url = "https://www.youtube.com/";}
              {url = "https://github.com/";}
              {url = "https://www.netflix.com/browse";}
              {url = "https://www.samskolan.se/login/";}
            ];
          };

          # firefox hardening
          # https://github.com/arkenfox/user.js/blob/master/user.js

          /*
          extraConfig = ''
            user_pref("extensions.autoDisableScopes", 0);
            user_pref("browser.aboutConfig.showWarning", false);

            // 0 auto, 1 light, 2 dark
            user_pref("blayout.css.prefers-color-scheme.content-override", 2);
          '';
          */
          /*
            user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
            user_pref("full-screen-api.ignore-widgets", true);
            user_pref("media.ffmpeg.vaapi.enabled", true);
            user_pref("media.rdd-vpx.enabled", true);
          '';
          */

          userChrome = ''
            /* Set minimum width below which tabs will not shrink (minimum 22px) */
            :root {
              --my-tab-min-width: 22px;
            }

            /* Essential rule for reducing minimum tab width */
            .tabbrowser-tab:not([pinned]){
              min-width: var(--my-tab-min-width) !important;
            }

            .tab-content {
              overflow: hidden !important;
            }

            /* Optional rules for widths below 40px */
            /* Reduce icon's right margin for less wasted space */
            .tabbrowser-tab:not([pinned]) .tab-icon-image {
              margin-right: 1px !important;
            }

            /* Adjust padding for better centering and less wasted space */
            .tabbrowser-tab:not([pinned]) .tab-content{
              padding-left: calc((var(--my-tab-min-width) - 22px)/2) !important;
              padding-right: calc((var(--my-tab-min-width) - 22px)/2) !important;
            }

            /* Reduce close button's padding for less wasted space */
            .tab-close-button.close-icon {
              padding-left: 0 !important;
              padding-right: 3px !important;
            }
          '';
          userContent = ''
            # Here too
          '';
        };

        test =
          upidapi
          // {
            id = 1;
            name = "test";
          };

        # For security testing and other stuff where you need a
        # profile where I can guarantee that i haven't fucked anything
        # upp / all behaviors are the default ones
        base = {
          id = 2;
          name = "base";
        };
      };
    };
  };
}
