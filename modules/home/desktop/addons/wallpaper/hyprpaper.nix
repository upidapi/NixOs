{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.desktop.addons.wallpaper.hyprpaper;
in {
  options.modules.home.desktop.addons.wallpaper.hyprpaper =
    mkEnableOpt "enables hyprpaper, a wallpaper daemion";

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      exec-once = ["hyprpaper"];
    };

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
