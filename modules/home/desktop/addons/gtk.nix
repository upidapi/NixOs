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
    # https://github.com/nix-community/home-manager/issues/3113
    home.packages = [
      pkgs.dconf
      pkgs.gnome-themes-extra
    ];

    gtk = {
      enable = true;
      # stylix handles this
      # enable dark mode
      # theme = {
      #   name = "Adwaita-dark";
      #   package = pkgs.gnome.gnome-themes-extra;
      # };
    };
  };
}
