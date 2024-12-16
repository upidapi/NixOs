{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.desktop.addons.bar.waybar;
in {
  options.modules.home.desktop.addons.bar.waybar =
    mkEnableOpt "enables a waybar status bar";

  # this is not actually setup
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      waybar # a bar
    ];
  };
}
