{
  mlib,
  lib,
  ...
}: let
  inherit (mlib) enable enableAnd;
  # inherit (lib) mkForce;
in {
  # Don't change this unless you reinstall from scratch.
  home.stateVersion = "23.11"; # Read comment
  modules.home = {
    suites.all = enable;

    # desktop.hypridle.lock = false;
    desktop.hypridle.suspend = false;

    misc.vms = {
      enable = true;
      w11 = enableAnd {
        isoName = "Win11_24H2_Eng_Debloated_x64.iso";
      };
    };
  };
}
