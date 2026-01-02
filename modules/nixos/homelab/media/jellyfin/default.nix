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
        "jellyfin/jellyseerr-api-key" = {
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

    systemd.services.jellyfin.serviceConfig.SupplementaryGroups = [
      # Access to /dev/dri
      "render"
      "video"
      # Access to /raid/media
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
          # R
          guest-17-1.maxParentalRatingSubScore = 17;
          guest-17-2.maxParentalRatingSubScore = 17;
          guest-17-3.maxParentalRatingSubScore = 17;
          guest-17-4.maxParentalRatingSubScore = 17;
          # PG-13
          guest-13-1.maxParentalRatingSubScore = 13;
          guest-13-2.maxParentalRatingSubScore = 13;
          guest-13-3.maxParentalRatingSubScore = 13;
          guest-13-4.maxParentalRatingSubScore = 13;
          # PG
          guest-10-1.maxParentalRatingSubScore = 10;
          guest-10-2.maxParentalRatingSubScore = 10;
          guest-10-3.maxParentalRatingSubScore = 10;
          guest-10-4.maxParentalRatingSubScore = 10;
          # G
          guest-0-1.maxParentalRatingSubScore = 0;
          guest-0-2.maxParentalRatingSubScore = 0;
          guest-0-3.maxParentalRatingSubScore = 0;
          guest-0-4.maxParentalRatingSubScore = 0;

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
            pathInfos = ["/raid/media/movies"];
            enableChapterImageExtraction = true;
            extractChapterImagesDuringLibraryScan = true;
            enableTrickplayImageExtraction = true;
            extractTrickplayImagesDuringLibraryScan = true;
            saveTrickplayWithMedia = true;
          };
          "Shows" = {
            enabled = true;
            contentType = "tvshows";
            pathInfos = ["/raid/media/tv"];
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
          Jellyseerr.keyPath = config.sops.secrets."jellyfin/jellyseerr-api-key".path;
        };
      };
    };
  };
}
