{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.desktop.addons.dunst;
in {
  options.modules.home.desktop.addons.eww =
    mkEnableOpt "enables eww";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      eww
    ];
  };
}
