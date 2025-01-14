{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.desktop.wallpaper.hyprpaper;
in {
  options.modules.home.desktop.wallpaper.hyprpaper =
    mkEnableOpt "enables hyprpaper, a wallpaper daemion";

  # FIXME: the bottom row of pixels don't get cleared on my laptop
  #  (it has fractional scaling)
  config = mkIf cfg.enable {
    home.packages = [pkgs.hyprpaper];

    services.hyprpaper = {
      enable = true;
      settings = {
        splash = false;
        preload = ["${./wallpapers/simple-tokyo-night.png}"];
        # set all to the same wallpaper
        wallpaper = [",${./wallpapers/simple-tokyo-night.png}"];
      };
    };
  };
}
