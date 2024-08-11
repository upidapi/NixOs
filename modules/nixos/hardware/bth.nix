{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.hardware.bth;
in {
  options.modules.nixos.hardware.bth =
    mkEnableOpt "enables bluetooth for the system";

  # it seems that bth won't work when there's no audio sources,
  # i.e nothing playing audio (i don't think this is still the case)
  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true; # enables support for Bluetooth
      powerOnBoot = true; # powers up the default Bluetooth controller on boot

      # doesn't fix anything'
      # settings = {
      #   General = {
      #      Experimental = "true";
      #
      #     ControllerMode = "bredr";
      #     AutoEnable = "true";
      #   };
      # };
    };

    services.blueman.enable = true;
  };
}
