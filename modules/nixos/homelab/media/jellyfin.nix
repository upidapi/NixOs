{
  config,
  lib,
  my_lib,
  ports,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkOption types literalExpression submodule;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.homelab.media.jellyfin;
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
  options.modules.nixos.homelab.media.jellyfin =
    mkEnableOpt
    "enables jellyfin for local movie hosting";

  options.services.jellyfin.libraries = mkOption {
    type = types.attrsOf (types.submodule
      ({name, ...}: {
        default = {};
        example = literalExpression ''
          {
            "hydra.example.com" = {
              serverAliases = [ "www.hydra.example.com" ];
              extraConfig = '''
                encode gzip
                root * /srv/http
              ''';
            };
          };
        '';
        description = ''
          Declarative specification of virtual hosts served by Caddy.
        '';
      }));
  };

  imports = [
    inputs.nixos-jellyfin.nixosModules.default
  ];

  # TODO: use the https://github.com/matt1432/nixos-jellyfin
  # REF: https://github.com/diogotcorreia/dotfiles/blob/db6db718a911c3a972c8b8784b2d0e65e981c770/hosts/hera/jellyfin.nix#L75
  config = mkIf cfg.enable {
    systemd.tmpfiles.settings = {
      "jellyfin-dir-create" = {
        "/var/lib/jellyfin/jellyfin-web".d = {
          group = "media";
          user = "jellyfin";
          mode = "700";
        };
        "/var/lib/jellyfin/config".d = {
          group = "media";
          user = "jellyfin";
          mode = "700";
        };
      };
    };

    systemd.services.jellyfin = let
      jcfg = config.services.jellyfin;
    in {
      serviceConfig.ExecStart = lib.mkOverride 25 (lib.concatStringsSep " " [
        "${jcfg.finalPackage}/bin/jellyfin"
        "--datadir '${jcfg.dataDir}'"
        "--configdir '${jcfg.configDir}'"
        "--cachedir '${jcfg.cacheDir}'"
        "--logdir '${jcfg.logDir}'"
        # "--ffmpeg '${cfg.ffmpegPackage}/bin/ffmpeg'"
        # "--webdir '${cfg.dataDir}/jellyfin-web'"
      ]);
    };

    hardware = {
      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          vaapiVdpau
          libvdpau-va-gl
          nvidia-vaapi-driver
          libva
        ];
        extraPackages32 = with pkgs; [vaapiVdpau];
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
    users.users.jellyfin.extraGroups = [
      "render"
      "video"
    ]; # Access to /dev/dri

    services = {
      jellyfin = {
        enable = true;
        group = "media";

        webPackage = pkgs.jellyfin-web;
        ffmpegPackage = pkgs.jellyfin-ffmpeg;
        package = pkgs.jellyfin;
        # finalPackage = lib.mkForce pkgs.jellyfin;

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
  };
}
