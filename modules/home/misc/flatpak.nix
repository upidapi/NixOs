{
  config,
  lib,
  mlib,
  inputs,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.misc.flatpak;
in {
  # https://github.com/in-a-dil-emma/declarative-flatpak
  imports = [
    inputs.declarative-flatpak.homeModules.default
  ];

  options.modules.home.misc.flatpak = mkEnableOpt "";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      flatpak
      gnome-software
    ];
    # flatpak pkg format
    # {remote}:{type}/{ref}/[{arch}]/{branch}[:{commit}]
    services.flatpak = {
      enable = true;
      forceRunOnActivation = false;
      remotes = {
        "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        "flathub-beta" = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
      };
    };
  };
}
