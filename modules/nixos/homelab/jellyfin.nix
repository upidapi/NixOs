{
  config,
  lib,
  my_lib,
  ports,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt enable;
  cfg = config.modules.nixos.homelab.jellyfin;
  # domainJellyfin = "jellyfin.upidapi.dev";
  # portJellyfin = 8096;
  # domainRadarr = "radarr.upidapi.dev";
  # portRadarr = 7878;
  # domainSonarr = "sonarr.upidapi.dev";
  # portSonarr = 8989;
  # domainJackett = "jackett.upidapi.dev";
  # portJackett = 9117;
  # domainBazarr = "bazarr.upidapi.dev";
  # portBazarr = config.services.bazarr.listenPort; # 6767
  #
  # bazarrDirectory = "/var/lib/bazarr";
  #
  # diskstationAddress = "192.168.1.4";
  # mediaGroup = "diskstation-media";
  #
  # transmissionGroup = config.services.transmission.group;
in {
  options.modules.nixos.homelab.jellyfin =
    mkEnableOpt
    "enables jellyfin for local movie hosting";

  imports = [
    inputs.nixos-jellyfin.nixosModules.default
  ];

  # TODO: use the https://github.com/matt1432/nixos-jellyfin
  # REF: https://github.com/diogotcorreia/dotfiles/blob/db6db718a911c3a972c8b8784b2d0e65e981c770/hosts/hera/jellyfin.nix#L75
  config = mkIf cfg.enable {
    services = {
      # https://www.rapidseedbox.com/blog/jellyseerr-guide#01
      jellyseerr = {
        enable = true;
        port = ports.jellyseerr;
        # openFirewall = true;
      };
      jellyfin = {
        enable = true;

        webPackage = pkgs.jellyfin-web;
        ffmpegPackage = pkgs.jellyfin-ffmpeg;
        package = pkgs.jellyfin;
        # finalPackage = pkgs.jellyfin;

        settings = {
          system = {
            serverName = "Jelly";
            quickConnectAvailable = false;
            isStartupWizardCompleted = true;

            enableGroupingIntoCollections = true;
            enableExternalContentInSuggestions = false;

            pluginRepositories = [
              {
                name = "Jellyfin Stable";
                url = "https://repo.jellyfin.org/releases/plugin/manifest-stable.json";
              }
              {
                name = "Intro Skipper";
                url = "https://raw.githubusercontent.com/jumoog/intro-skipper/master/manifest.json";
              }
              {
                name = "Merge Versions Plugin";
                url = "https://raw.githubusercontent.com/danieladov/JellyfinPluginManifest/master/manifest.json";
              }
            ];

            enableSlowResponseWarning = false;
          };

          # Doesn't exist, maybe create a pr to fix it
          # network = {
          #   internalHttpPort = ports.jellyfin;
          # };

          # branding = let
          #   jellyTheme = pkgs.stdenv.mkDerivation {
          #     name = "Ultrachromic";
          #     src = jellyfin-ultrachromic-src;
          #     postInstall = "cp -ar $src $out";
          #   };
          #
          #   importFile = file: fileContents "${jellyTheme}/${file}";
          # in {
          #   customCss = ''
          #     /* Base theme */
          #     ${importFile "base.css"}
          #     ${importFile "accentlist.css"}
          #     ${importFile "fixes.css"}
          #
          #     ${importFile "type/dark_withaccent.css"}
          #
          #     ${importFile "rounding.css"}
          #     ${importFile "progress/floating.css"}
          #     ${importFile "titlepage/title_banner-logo.css"}
          #     ${importFile "header/header_transparent.css"}
          #     ${importFile "login/login_frame.css"}
          #     ${importFile "fields/fields_border.css"}
          #     ${importFile "cornerindicator/indicator_floating.css"}
          #
          #     /* Style backdrop */
          #     .backdropImage {filter: blur(18px) saturate(120%) contrast(120%) brightness(40%);}
          #
          #     /* Custom Settings */
          #     :root {--accent: 145,75,245;}
          #     :root {--rounding: 12px;}
          #
          #     /* https://github.com/CTalvio/Ultrachromic/issues/79 */
          #     .skinHeader {
          #       color: rgba(var(--accent), 0.8);;
          #     }
          #     .countIndicator,
          #     .fullSyncIndicator,
          #     .mediaSourceIndicator,
          #     .playedIndicator {
          #       background-color: rgba(var(--accent), 0.8);
          #     }
          #   '';
          # };

          encoding = {
            hardwareAccelerationType = "nvenc";
            hardwareDecodingCodecs = [
              "h264"
              "hevc"
              "mpeg2video"
              "mpeg4"
              "vc1"
              "vp8"
              "vp9"
              "av1"
            ];
            allowHevcEncoding = false;
            enableThrottling = false;
            enableTonemapping = true;
            downMixAudioBoost = 1;
          };
        };
      };
      radarr = {
        enable = true;
        settings = {
          # update.mechanism = "internal";
          server = {
            # urlbase = "localhost";
            port = ports.radarr;
            # bindaddress = "*";
          };
        };
      };
      sonarr = {
        enable = true;
        settings = {
          # update.mechanism = "internal";
          server = {
            # urlbase = "localhost";
            port = ports.sonarr;
            # bindaddress = "*";
          };
        };
      };
      jackett = {
        enable = true;
        port = ports.jackett;
      };
      bazarr = {
        enable = true;
        listenPort = ports.bazarr;
      };

      caddy.virtualHosts = {
        "jellyfin.upidapi.dev".extraConfig = ''
          encode zstd gzip

          header {
            # Enable HTTP Strict Transport Security (HSTS)
            Strict-Transport-Security "max-age=31536000;"
            # Enable cross-site filter (XSS) and tell browser to block detected attacks
            X-XSS-Protection "1; mode=block"
            # Disallow the site to be rendered within a frame (clickjacking protection)
            X-Frame-Options "DENY"
            # Avoid MIME type sniffing
            X-Content-Type-Options "nosniff"
            # Prevent search engines from indexing (optional)
            X-Robots-Tag "none"
            # Server name removing
            -Server
          }

          @notblacklisted {
            not {
              path /metrics*
            }
          }

          reverse_proxy @notblacklisted http://localhost:8096
        '';
      };
    };

    # users.groups.${mediaGroup} = {};
    users.users = {
      # ${config.services.radarr.user}.extraGroups = [mediaGroup transmissionGroup];
      # ${config.services.sonarr.user}.extraGroups = [mediaGroup transmissionGroup];
      # ${config.services.bazarr.user}.extraGroups = [mediaGroup];
    };

    /*
    services.caddy.virtualHosts = {
      ${domainJellyfin} = {
        # enableACME = true;
        extraConfig = ''
          reverse_proxy localhost:${toString portJellyfin}
        '';
      };
    };
    */
  };
}
