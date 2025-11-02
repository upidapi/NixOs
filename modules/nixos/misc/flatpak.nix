{
  config,
  lib,
  mlib,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.misc.flatpak;
in {
  # https://github.com/in-a-dil-emma/declarative-flatpak
  imports = [
    inputs.declarative-flatpak.nixosModules.default
  ];

  options.modules.nixos.misc.flatpak = mkEnableOpt "";

  config = mkIf cfg.enable {
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
