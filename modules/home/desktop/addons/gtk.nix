{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.desktop.addons.gtk;
in {
  options.modules.home.desktop.addons.gtk =
    mkEnableOpt "enables gtk, a gui component lib";

  config = mkIf cfg.enable {
    gtk = {
      enable = true;
      # enable dark mode
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome.gnome-themes-extra;
      };
    };
  };
}
