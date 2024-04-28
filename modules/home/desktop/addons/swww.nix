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
in {
  options.modules.home.desktop.addons.swww =
    mkEnableOpt "enables swww, a wallpaper daemion";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      swww # wallpaper daemions
    ];
  };
}
