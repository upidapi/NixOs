# bth.nix
{
  lib,
  config,
  pkgs,
  ...
}: {
  config = {
    hardware.bluetooth = {
      enable = true; # enables support for Bluetooth
      powerOnBoot = true; # powers up the default Bluetooth controller on boot

      # settings = {
      #   General = {
      #     Experimental = "true";
      #
      #     ControllerMode = "bredr";
      #     AutoEnable = "true";
      #   };
      # };
    };

    services.blueman.enable = true;
  };
}
