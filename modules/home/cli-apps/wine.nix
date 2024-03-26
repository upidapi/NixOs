{
  config,
  pkgs,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.cli-apps.wine;
in {
  options.modules.home.cli-apps.wine =
    mkEnableOpt "Whether or not to enable wine";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # winePackages.unstable  # this causes some collision, idk how to fix it, might be due to steam, r2modman or wine
      winetricks
      wine64Packages.unstable
    ];
  };
}
