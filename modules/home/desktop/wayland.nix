{
  config,
  mlib,
  lib,
  pkgs,
  ...
}: let
  inherit (mlib) mkEnableOpt;
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
        XDG_SESSION_TYPE = "wayland";
      };

      packages = with pkgs; [
        wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      ];
    };

    # handles desktop programs interactions
    xdg.portal = {
      enable = true;

      config = {
        common = {
          default = ["hyprland"];
        };
        hyprland = {
          default = ["gtk" "hyprland"];
        };
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
        xdg-desktop-portal-hyprland
      ];
      xdgOpenUsePortal = true;

      /*
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];

      configPackages = [
        pkgs.hyprland
      ];
      */
    };
  };
}
