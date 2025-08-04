{
  config,
  mlib,
  lib,
  pkgs,
  ...
}: let
  inherit (mlib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.desktop.bar.waybar;
in {
  options.modules.home.desktop.bar.waybar =
    mkEnableOpt "enables a waybar status bar";

  # this is not actually setup
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      waybar # a bar
    ];
  };
}
