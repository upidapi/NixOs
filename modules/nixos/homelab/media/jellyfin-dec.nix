{
  config,
  lib,
  my_lib,
  ports,
  pkgs,
  inputs,
  self,
  ...
}: let
  inherit (lib) mkIf mkOption types literalExpression submodule;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.homelab.media.jellyfin;
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
    # users.users.jellyfin.extraGroups = [
    #   "render"
    #   "video"
    # ]; # Access to /dev/dri

    sops.secrets =
      {
      }
      // lib.mapAttrs (_: x: (x
        // {
          owner = config.services.jellyfin.user;
          sopsFile = "${self}/secrets/server.yaml";
        })) {
        "jellyfin/users/admin" = {};
        "jellyfin/jellyseerr-api-key" = {};
      };

    systemd.services.jellyfin.serviceConfig.SupplementaryGroups = [
      "render"
      "video"
    ];

    services = {
      declarative-jellyfin = {
        enable = true;
        group = "media";
        system = {
          isStartupWizardCompleted = true;
          trickplayOptions = {
            enableHwAcceleration = true;
            enableHwEncoding = true;
          };
          UICulture = "en";
        };
        network = {
          internalHttpPort = ports.jellyfin;
          publicHttpPort = ports.jellyfin;
        };
        users = {
          admin = {
            mutable = false;
            permissions = {
              isAdministrator = true;
            };
            hashedPasswordFile = config.sops.secrets."jellyfin/users/admin".path;
          };
          # "gags5" = {
          #   permissions.enableAllFolders = false;
          #   preferences.enabledLibraries = [ "Movies" "Shows" ];
          # };
          # "guacamole" = {
          #   permissions.enableAllFolders = false;
          #   preferences.enabledLibraries = [ "Movies" "Shows" ];
          # };
          # "alex" = {
          #   permissions.enableAllFolders = false;
          #   preferences.enabledLibraries = [ "Movies" "Shows" ];
          # };
        };
        libraries = {
          "Movies" = {
            enabled = true;
            contentType = "movies";
            pathInfos = ["/srv/radarr"];
            enableChapterImageExtraction = true;
            extractChapterImagesDuringLibraryScan = true;
            enableTrickplayImageExtraction = true;
            extractTrickplayImagesDuringLibraryScan = true;
            saveTrickplayWithMedia = true;
          };
          "Shows" = {
            enabled = true;
            contentType = "tvshows";
            pathInfos = ["/data/sonarr"];
            enableChapterImageExtraction = true;
            extractChapterImagesDuringLibraryScan = true;
            enableTrickplayImageExtraction = true;
            extractTrickplayImagesDuringLibraryScan = true;
            saveTrickplayWithMedia = true;
          };
          # "Photos" = {
          #   enabled = true;
          #   contentType = "homevideos";
          #   pathInfos = ["/data/Photos"];
          #   enableChapterImageExtraction = true;
          #   extractChapterImagesDuringLibraryScan = true;
          #   enableTrickplayImageExtraction = true;
          #   extractTrickplayImagesDuringLibraryScan = true;
          #   saveTrickplayWithMedia = true;
          # };
        };
        encoding = {
          enableHardwareEncoding = true;
          hardwareAccelerationType = "vaapi";
          enableDecodingColorDepth10Hevc = true;
          allowHevcEncoding = true;
          allowAv1Encoding = true;
          hardwareDecodingCodecs = [
            "h264"
            "hevc"
            "mpeg2video"
            "vc1"
            "vp9"
            "av1"
          ];
        };
        apikeys = {
          Jellyseerr.keyPath = config.sops.secrets."jellyfin/jellyseerr-api-key".path;
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
  };
}
