{my_lib, ...}: let
  inherit (my_lib.opt) enable;
in {
  # Don't change this unless you reinstall from scratch.
  home.stateVersion = "23.11"; # Read comment
  modules.home = {
    suites.all = enable;
  };
}
