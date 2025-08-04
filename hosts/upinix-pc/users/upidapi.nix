{
  mlib,
  lib,
  ...
}: let
  inherit (mlib.opt) enable;
  inherit (lib) mkForce;
in {
  # Don't change this unless you reinstall from scratch.
  home.stateVersion = "23.11"; # Read comment
  modules.home = {
    suites.all = enable;

    desktop.hypridle.enable = mkForce false;
  };
}
