{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.desktop.wallpaper.swww;

  startSwww = pkgs.writeShellScriptBin "start-swww" ''
    ${pkgs.swww}/bin/swww-daemon & sleep 1
    ${pkgs.swww}/bin/swww img \
      ${./wallpapers/simple-tokyo-night.png} \
      --transition-type=none
  '';
in {
  options.modules.home.desktop.wallpaper.swww =
    mkEnableOpt "enables swww, a wallpaper daemion";

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      exec-once = ["bash ${startSwww}/bin/start-swww"];
    };

    home.packages = with pkgs; [
      swww # wallpaper daemions
    ];
  };
}
