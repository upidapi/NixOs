{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.home.desktop.wayland;
in {
  options.modules.home.desktop.wayland =
    mkEnableOpt "enables wayland, a display compositor";

  config = mkIf cfg.enable {
    # hint electron apps that you're using wayland
    home = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };

      packages = with pkgs; [
        wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      ];
    };

    # handles desktop programs interactions
    xdg.portal = {
      enable = true;

      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];

      configPackages = [
        pkgs.hyprland
      ];
    };
  };
}
