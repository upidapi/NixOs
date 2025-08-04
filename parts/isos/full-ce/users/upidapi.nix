{
  # pkgs,
  # inputs,
  mlib,
  ...
}: let
  inherit (mlib) enable;
in {
  # Dont change this unless you reinsall from scratch.
  home.stateVersion = "23.11"; # Read comment
  modules.home.suites.all = enable;
}
