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
  options.modules.nixos.hardware.sound =
    mkEnableOpt "enables sound for the system";

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.pamixer
      pkgs.pulseaudio
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
      wireplumber.enable = true;
      # If you want to use JACK applications, uncomment this
      # jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      # media-session.enable = true;
    };
  };
}
