{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.desktop.addons.waybar;
in {
  options.modules.home.desktop.addons.waybar =
    mkEnableOpt "enables a waybar status bar";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      waybar # a bar (i think the top thing)
    ];
  };
}
