{
  # pkgs,
  # inputs,
  my_lib,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  # Dont change this unless you reinsall from scratch.
  home.stateVersion = "23.11"; # Read comment
  modules.home.suites.all = enable;
}
