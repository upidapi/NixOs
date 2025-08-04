{
  config,
  pkgs,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.apps.bitwarden;
in {
  options.modules.home.apps.bitwarden =
    mkEnableOpt "Whether or not to enable bitwarden";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bitwarden-desktop
      bitwarden-cli
    ];
  };
}
