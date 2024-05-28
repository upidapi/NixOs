{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.desktop.addons.swww;

  startSwww = pkgs.writeShellScriptBin "start-swww-d" ''
     ${pkgs.swww}/bin/swww init &
     sleep 1

    ${pkgs.swww}/bin/swww img ${config.stylix.image}
  '';
in {
  options.modules.home.desktop.addons.swww =
    mkEnableOpt "enables swww, a wallpaper daemion";

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      exec-once = ["bash ${startSwww}/bin/start-swww-d"];
    };

    home.packages = with pkgs; [
      swww # wallpaper daemions
    ];
  };
}
