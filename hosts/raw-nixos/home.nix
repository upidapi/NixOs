{
  osConfig,
  pkgs,
  inputs,
  my_lib,
  ...
}: let
  inherit (my_lib.opt) enable;
in rec {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "upidapi";
  home.homeDirectory = "/home/upidapi";
  home.stateVersion = "23.11"; # Please read the comment before changing.
}
