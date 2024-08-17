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

  # EXPLORE: https://github.com/qutebrowser/qutebrowser
  #  a vim like browser with minimal gui and a focus on the keyboard

  # TODO: add https://github.com/ray-lothian/UserAgent-Switcher

  # https://www.reddit.com/r/imdb/comments/109gc27/is_there_any_working_method_to_hide_the_episodes/
  # add to sytlus to fix netflix spoilters
  /*
  @-moz-document domain("www.netflix.com") {
    span.duration:not(:hover), div.titleCard-title_index:not(:hover)  {
        color: rgb(0, 0, 0);
        background-color: rgb(0, 0, 0);
    }
  }
  */

  # possibly might disable the restore screen
  # browser.sessionstore.resume_from_crash
  config = mkIf cfg.enable {
    home.sessionVariables = {
      BROWSER = "firefox";
    };

    programs.firefox = rec {
      enable = true;
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        extraPolicies = {
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
          /*
          ExtentionSettings = {
            # Vimium
            # tokyo-night-theme
            "{4520dc08-80f4-4b2e-982a-c17af42e5e4d}" = {
              "installation_mode" = "force_installed";
              "install_url" = "https://addons.mozilla.org/firefox/downloads/file/3952418/tokyo_night_milav-1.0.xpi";
              "default_area" = "menupanel";
            };
          };
          */
        };
      };
      profiles = {
        "${config.home.username}" = {
          id = 0;
          name = config.home.username;
          search = {
            force = true;
            default = "DuckDuckGo";
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
              # add noogle.dev

              "noogle" = {
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
                definedAliases = ["@ng" "@noogle"];
              };

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
                definedAliases = ["@np" "@nixpkgs"];
              };
              "NixOS Wiki" = {
                urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
                iconUpdateURL = "https://nixos.wiki/favicon.png";
                updateInterval = 24 * 60 * 60 * 1000;
                definedAliases = ["@nw" "@nixwiki"];
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
              # "Google".metaData.hidden = true;
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

            vimium

            ublock-origin

            # un clickbait youtube
            dearrow

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
              {url = "https://noogle.dev/";}
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

          # Custom CSS style options
          userChrome = with config.lib.stylix.colors.withHashtag; ''
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


                 /*
                 the following is copied from
                 https://github.com/GideonWolfe/nix/blob/main/configs/users/gideon/configs/firefox/firefox.nix
                 */

            /*------------- STATUS PANEL ------------------*/


            /* color of url loading bar at bottom left */
            #statuspanel-label {
            	background-color: ${base00} !important;
            	color: ${base0E} !important;
            	border-color: ${base0D} !important;
            }

            /* Change background color for both private and non-private windows */
            @-moz-document url("chrome://browser/content/browser.xhtml") {
            	/* Non-private window background color */
            	#appcontent, #appcontent tabpanels, browser[type="content-primary"], browser[type="content"] > html, browser[type="content"] > html > body {
            		background-color: ${base00} !important;
              }
            }


            /* Hover tooltip style, only themes some ie. refresh button*/
            tooltip {
            	color: ${base05} !important;
            	background-color: ${base00} !important;
            	-moz-appearance: none !important;
            	border: 1px solid ${base0D};
            	border-radius: 2;
            }

            /*--------------- TOOLBAR ----------------*/

            /* Changes color of toolbar */
            #navigator-toolbox{ --toolbar-bgcolor: ${base00} }

            /* List all tabs dropdown button */
            #alltabs-button { color: ${base0D} !important; }

            /* Shield icon */
            #tracking-protection-icon-box {
            	color: ${base0C} !important;
            }
            #urlbar-input-container[pageproxystate="valid"] #tracking-protection-icon-box:not([hasException])[active] > #tracking-protection-icon{
            	color: ${base08} !important;
            }

            /* Back button coloring color */
            #back-button:not([disabled="true"]):not([open="true"]):not(:active) .toolbarbutton-icon {
            	background-color: ${base00} !important;
            	color: ${base09} !important;
            }

            /* Back button coloring */
            #forward-button{
            	color: ${base0B} !important;
            }

            /* Refresh button coloring */
            #reload-button{
            	color: ${base0D} !important;
            }

            /* Cancel Loading button coloring */
            #stop-button{
            	color: ${base08} !important;
            }

            /* Downloads button coloring */
            #downloads-button{
            	color: ${base0E} !important;
            }
            /* example of setting image as icon https://www.reddit.com/r/FirefoxCSS/comments/cy8w4d/new_tab_button_customization/ */
            /* New Tab Buttons */
            /* the weirdness of these buttons https://www.reddit.com/r/FirefoxCSS/comments/12mjsk1/change_color_of_add_new_tab_button/ */
            :is(#new-tab-button, #tabs-newtab-button) > .toolbarbutton-icon {
            	color: ${base0C} !important;
            }
            :is(#new-tab-button, #tabs-newtab-button):hover > .toolbarbutton-icon {
            	color: ${base0C} !important;
            }

            /* Hamburger Menu icon in toolbar */
            #PanelUI-menu-button {
            	color: ${base0E} !important;
            }
            /* Extensions icon in toolbar */
            #unified-extensions-button{
            	color: ${base0F} !important;
            }

            /* Disable favorite star button */
            #star-button-box { display:none !important; }

            /* Reader view icon */
            #reader-mode-button-icon { color: ${base09} !important }
            #reader-mode-button[readeractive] > .urlbar-icon {
            	color: ${base0E} !important
            }


            /*-----------------------------------------*/

            /* */

            /*----------------- TABS ------------------*/

            /* Disable Favicons */
            .tab-icon-image {
            	display: none !important;
            }

            /* Colors text and background of tab label */
            .tabbrowser-tab .tab-label {
            	color: ${base05} !important;
            	background-color: ${base00} !important;
            }

            /* Text of secondary tab text (ie. "Playing") */
            .tab-secondary-label {
            	color: ${base0D};
            }
            /* Secondary text when audio is muted */
            .tab-secondary-label[muted] {
            	color: ${base08};
            }

            /* Colors text and background of tab label (selected)*/
            .tabbrowser-tab[selected="true"] .tab-label {
            	color: ${base0B} !important;
            	background-color: ${base00} !important;
            	font-weight: bold !important;
            }

            /* Background color of tab itself (selected) */
            .tabbrowser-tab[selected] .tab-content {
            	background-color: ${base00} !important;
            }

            .tabbrowser-tab .tab-close-button {
            	color: ${base08};
            }

            /* Style for Magnifying glass icon in search bar */
            #urlbar:not(.searchButton) > #urlbar-input-container > #identity-box[pageproxystate="invalid"] {
            	color: ${base0E} !important;
            }

            /* Style for close tab buttons */
            .tabbrowser-tab:not([pinned]) .tab-close-button {
            	color: ${base0D} !important;
            }
            .tabbrowser-tab:not([pinned]):hover .tab-close-button {
            	color: ${base08} !important;
            	font-weight: bold !important;
            }

            /*-----------------------------------------*/


            .findbar {
            	background-color: ${base00};
            	-moz-appearance: none !important;
            }
            .findbar-container {
            	background-color: ${base00};
            }


            /* Search box when no results found */
            .findbar-textbox[status="notfound"] {
              background-color: ${base00} !important;
              color: ${base08} !important;
            }

            /* Arrow buttons when no search entered */
            .findbar-find-previous[disabled="true"] > .toolbarbutton-icon,
            .findbar-find-next[disabled="true"] > .toolbarbutton-icon {
            	fill: ${base08} !important;
            }
            /* Arrows when results found */
            .findbar-find-previous {
            	fill: ${base0A} !important;
            }
            .findbar-find-next {
            	fill: ${base0B} !important;
            }

            /* Close Icon */
            findbar > .close-icon{
            	background-color: ${base00} !important;
            	pointer-events: auto;
            }
            .close-icon.findbar-closebutton {
              fill: ${base08} !important;
            }

            /* Color of "Phrase not Found" */
            .findbar-find-status{
            	color: ${base08};
            }

            /* Replace checkboxes with buttons */
            findbar .checkbox-check {
            	display: none !important;
            }
            findbar checkbox {
            	background: ${base00};
            	transition: 0.1s ease-in-out;
            	border: 1px solid ${base0D};
            	border-radius: 2;
            	padding: 2px 4px;
            	margin: -2px 4px !important;
            }
            findbar checkbox[checked="true"] {
            	background: ${base00};
            	color: ${base0B};
            	transition: 0.1s ease-in-out;
            }
            .found-matches {
            	color: ${base0B};
            }


            /*-----------------------------------------*/

            /*------------- SITE SECURITY ICON --------*/

            /* Green */
            #identity-box[pageproxystate="valid"].verifiedDomain #identity-icon {
            	fill: ${base0B} !important;
            	fill-opacity: 1 !important;
            	transition: 100ms linear !important;
            }
            #identity-box[pageproxystate="valid"].mixedActiveBlocked #identity-icon {
            	fill: ${base0B} !important;
            	fill-opacity: 1 !important;
            	transition: 100ms linear !important;
            }
            #identity-box[pageproxystate="valid"].verifiedIdentity #identity-icon {
            	fill: ${base0B} !important;
            	fill-opacity: 1 !important;
            	transition: 100ms linear !important;
            }
            #identity-popup[connection^="secure"] .identity-popup-security-connection {
            	fill: ${base0B} !important;
            }

            /* Red */
            #identity-box[pageproxystate="valid"].notSecure #identity-icon {
            	fill: ${base08} !important;
            	fill-opacity: 1 !important;
            	transition: 100ms linear !important;
            }
            #identity-box[pageproxystate="valid"].mixedActiveContent #identity-icon {
            	fill: ${base08} !important;
            	fill-opacity: 1 !important;
            	transition: 100ms linear !important;
            }
            #identity-box[pageproxystate="valid"].insecureLoginForms #identity-icon {
            	fill: ${base08} !important;
            	fill-opacity: 1 !important;
            	transition: 100ms linear !important;
            }
            .identity-popup-security-connection {
            	fill: ${base08};
            }

            /* Orange */
            #identity-box[pageproxystate="valid"].mixedDisplayContent #identity-icon {
            	fill: ${base09} !important;
            	fill-opacity: 1 !important;
            	transition: 100ms linear !important;
            }
            #identity-popup[mixedcontent~="passive-loaded"][isbroken] .identity-popup-security-connection {
            	fill: ${base09} !important;
            }

            /* Yellow */
            #identity-box[pageproxystate="valid"].mixedDisplayContentLoadedActiveBlocked #identity-icon {
            	fill: ${base0A} !important;
            	fill-opacity: 1 !important;
            	transition: 100ms linear !important;
            }
            #identity-box[pageproxystate="valid"].certUserOverridden #identity-icon {
            	fill: ${base0A} !important;
            	fill-opacity: 1 !important;
            	transition: 100ms linear !important;
            }

            /*-----------------------------------------*/

            /*------------- CONTEXT MENUS  --------*/

            /* TODO Star doesn't work?*/
            #context-back {
            	color: ${base09} !important;
            }
            #context-forward {
            	color: ${base0B} !important;
            }
            #context-reload {
            	color: ${base0D} !important;
            }
            #context-stop {
            	color: ${base08} !important;
            }
            #context-star {
            	color: ${base0A} !important;
            }

            /*-----------------------------------------*/

            /* TODO this should style reader? idk if the reader pages start with about:reader*/
            @-moz-document url-prefix("about:reader") {
              body.dark {
                color: ${base05} !important;
                background-color: ${base00} !important;
              }
              body.light {
                color: ${base00} !important;
                background-color: ${base05}!important;
              }
              body.sepia {
                color: ${base0D} !important;
                background-color: ${base00} !important;
              }

              body.serif {
                font-family: serif !important;
              }
              body.sans-serif {
                font-family: sans-serif !important;
              }
            }




            /*-------------- TODO: ----------------------*/
            /* Change context menu separators *\
            /* Close window button *\
            /* Reader view button when reader is active *\
          '';

          userContent = with config.lib.stylix.colors.withHashtag; ''
            /* change background of new tab page */
            @-moz-document url("about:newtab"),
            url("about:home")
            {
              :root[lwt-newtab-brighttext] {
                --newtab-background-color: ${base00} !important;
              }
            }
          '';
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
