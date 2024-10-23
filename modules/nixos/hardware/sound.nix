{
  lib,
  my_lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
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

    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
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
        };
      };
      # If you want to use JACK applications, uncomment this
      # jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      # media-session.enable = true;
    };
  };
}
