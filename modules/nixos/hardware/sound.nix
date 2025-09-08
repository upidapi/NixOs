{
  lib,
  mlib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt enable;
  cfg = config.modules.nixos.hardware.sound;
in {
  options.modules.nixos.hardware.sound = mkEnableOpt "enables sound for the system";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pamixer
      pulseaudio
    ];

    # Enable sound with pipewire.

    # apparently not needed (https://github.com/NixOS/nixpkgs/issues/319809#issuecomment-2167912680)
    # sound.enable = true;

    security.rtkit = enable;
    services = {
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber = {
          enable = true;
          # fix https://www.reddit.com/r/linux/comments/1em8biv/psa_pipewire_has_been_halving_your_battery_life/
          # remove this when not needed?
          extraConfig = {
            "10-disable-camera" = {
              "wireplumber.profiles" = {
                main."monitor.libcamera" = "disabled";
              };
            };
            "10-bluez" = {
              "monitor.bluez.properties" = {
                # Disable low quality codecs, such as HSP/HFP.
                "bluez5.autoswitch-profile" = false;
                "bluez5.enable-hfp" = false;
                "bluez5.enable-hsp" = false;

                "bluez5.enable-sbc-xq" = false; # Disable SBC-XQ, as it is not supported by most devices.
                "bluez5.enable-msbc" = false;
                "bluez5.enable-hw-volume" = true;
                # bluez5.codecs are all enabled by default
                "bluez5.a2dp.ldac.quality" = "hq";
              };
            };
          };
        };
        extraConfig.pipewire = {
          "10-sample-rate" = {
            "context.properties" = {
              "default.clock.rate" = 44100;
              "default.clock.allowed-rates" = [
                44100
                48000
                88200
                96000
                192000
              ];

              # Fix stuttering
              "default.clock.quantum" = 512;
              "default.clock.min-quantum" = 256;
              "default.clock.max-quantum" = 2048;
            };
          };
        };
        # If you want to use JACK applications, uncomment this
        # jack.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        # media-session.enable = true;
      };
    };
  };
}
