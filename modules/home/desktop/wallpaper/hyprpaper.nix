{
  config,
  mlib,
  lib,
  pkgs,
  ...
}: let
  inherit (mlib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.desktop.wallpaper.hyprpaper;
in {
  options.modules.home.desktop.wallpaper.hyprpaper =
    mkEnableOpt "enables hyprpaper, a wallpaper daemion";

  config = mkIf cfg.enable {
    home.packages = [pkgs.hyprpaper];

    services.hyprpaper = {
      enable = true;
      settings = {
        splash = false;
        # set by stylix
        # preload = ["${./wallpapers/simple-tokyo-night.png}"];
        # set all to the same wallpaper
        # wallpaper = [",${./wallpapers/simple-tokyo-night.png}"];
      };
    };
  };
}
