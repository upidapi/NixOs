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
  inherit (mlib.opt) mkEnableOpt;
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
    # ];

    sops.secrets =
      {
        "jellyfin/jellyseerr-api-key" = {
          owner = config.services.jellyfin.user;
          sopsFile = "${self}/secrets/server.yaml";
        };
      }
      // lib.pipe ["admin" "smiley" "mari" "pablo" "cave" "tv" "guest"] [
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
      ];
    systemd.services.jellyfin.serviceConfig.SupplementaryGroups = [
      # Access to /dev/dri
      "render"
      "video"
      # Access to /media
      "media"
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
        users = let
          pswHash = user: config.sops.secrets."jellyfin/users/${user}/passwordHash".path;
        in {
          admin = {
            mutable = false;
            permissions = {
              isAdministrator = true;
            };
            loginAttemptsBeforeLockout = null;
            hashedPasswordFile = pswHash "admin";
          };
          smiley = {
            mutable = false;
            loginAttemptsBeforeLockout = null;
            hashedPasswordFile = pswHash "smiley";
          };
          mari = {
            mutable = false;
            loginAttemptsBeforeLockout = null;
            hashedPasswordFile = pswHash "mari";
          };
          pablo = {
            mutable = false;
            loginAttemptsBeforeLockout = null;
            hashedPasswordFile = pswHash "pablo";
          };
          cave = {
            mutable = false;
            loginAttemptsBeforeLockout = null;
            maxParentalAgeRating = 17;
            hashedPasswordFile = pswHash "cave";
          };
          tv = {
            mutable = false;
            loginAttemptsBeforeLockout = null;
            maxParentalAgeRating = 13;
            hashedPasswordFile = pswHash "tv";
          };
          guest = {
            mutable = false;
            loginAttemptsBeforeLockout = null;
            hashedPasswordFile = pswHash "guest";
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
            pathInfos = ["/media/movies"];
            enableChapterImageExtraction = true;
            extractChapterImagesDuringLibraryScan = true;
            enableTrickplayImageExtraction = true;
            extractTrickplayImagesDuringLibraryScan = true;
            saveTrickplayWithMedia = true;
          };
          "Shows" = {
            enabled = true;
            contentType = "tvshows";
            pathInfos = ["/media/tv"];
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
    };
  };
}
