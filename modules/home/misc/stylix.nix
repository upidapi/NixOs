{
  config,
  lib,
  my_lib,
  inputs,
  pkgs,
  self,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.misc.stylix;
in {
  options.modules.home.misc.stylix = mkEnableOpt "enables stylix";

  imports = [inputs.stylix.homeManagerModules.stylix];

  config.stylix = mkIf cfg.enable {
    enable = true;

    image = "${self}/modules/home/desktop/addons/wallpaper/wallpapers/simple-tokyo-night.png";
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-city-dark.yaml";

    fonts = {
      sizes.terminal = 10;

      # TODO: change (this is the defaults)
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      monospace = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans Mono";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };
}
