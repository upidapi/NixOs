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

    # TODO: don't do that
    # use a hand made one instead since this once kinda sucks
    targets.vesktop.enable = false;

    image = "${self}/modules/home/desktop/addons/wallpaper/wallpapers/simple-tokyo-night.png";
    polarity = "dark";
    base16Scheme =
      builtins.mapAttrs
      (_: color: builtins.substring 1 (-1) color)
      {
        # Default background
        base00 = "#1a1b26"; # i.e bg
        # Alternate background
        base01 = "#16161e"; # i.e bg_dark
        # Selection background
        base02 = "#292e42"; # ? i.e bg_highlight
        base03 = "#414868"; # i.e terminal_black
        # Alternate text
        base04 = "#757c9f"; # idk
        # Default text
        base05 = "#a9b1d6"; # i.e fg_Dark
        base06 = "#b4bde5"; # idk
        base07 = "#c0caf5"; # i.e fg
        # Error
        base08 = "#ff757f";
        # Urgent
        base09 = "#ffc777";
        # Warning
        base0A = "#ffc777";
        base0B = "#c3e88d";
        base0C = "#86e1fc";
        base0D = "#82aaff";
        base0E = "#fca7ea";
        base0F = "#c53b53";
      };
    /*
    {
      base00 = "#222436";
      base01 = "#1e2030";
      base02 = "#2d3f76";
      base03 = "#636da6";
      base04 = "#828bb8";
      base05 = "#3b4261";
      base06 = "#828bb8";
      base07 = "#c8d3f5";
      base08 = "#ff757f";
      base09 = "#ffc777";
      base0A = "#ffc777";
      base0B = "#c3e88d";
      base0C = "#86e1fc";
      base0D = "#82aaff";
      base0E = "#fca7ea";
      base0F = "#c53b53";
    };
    */
    # "${pkgs.base16-schemes}/share/themes/tokyo-night-moon.yaml";

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
