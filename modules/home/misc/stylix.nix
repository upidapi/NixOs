{
  config,
  lib,
  mlib,
  inputs,
  pkgs,
  self,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.misc.stylix;
in {
  options.modules.home.misc.stylix = mkEnableOpt "enables stylix";

  imports = [inputs.stylix.homeModules.stylix];

  config.stylix = mkIf cfg.enable {
    enable = true;

    autoEnable = false;

    # targets = {
    #   # default to no profiles
    #   firefox.profileNames = ["${config.home.username}" "test"];
    # };

    image = "${self}/modules/home/desktop/wallpaper/wallpapers/simple-tokyo-night.png";
    polarity = "dark";
    base16Scheme =
      builtins.mapAttrs
      (_: color: builtins.substring 1 (-1) color)
      {
        # Default background
        base00 = "#1a1b26"; # i.e bg
        # Alternate background
        # (i think this should actually be lighter than base00)
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
        base0A = "#fcf56c";
        base0B = "#c3e88d";
        base0C = "#86e1fc";
        base0D = "#82aaff";
        base0E = "#fca7ea";
        base0F = "#c53b53";

        # color10 = "#"; # Darker Background
        # color11 = "#"; # The Darkest Background
        # color12 = "#ff3240"; # red  #ff0010
        # color13 = "#fcf125"; # yellow
        # color14 = "#adff32"; # green
        # color15 = "#32cdfc"; # cyan
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

    # REF: https://github.com/Permafrozen/dot-nixe/blob/e4be619686f20b5d87e7ac9b5628b34257c2edee/configs/pkgs/stylix/default.nix#L5
    cursor = let
      mcmojave = pkgs.fetchFromGitHub {
        owner = "vinceliuice";
        repo = "McMojave-cursors";
        rev = "7d0bfc1f91028191cdc220b87fd335a235ee4439";
        hash = "sha256-4YqSucpxA7jsuJ9aADjJfKRPgPR89oq2l0T1N28+GV0=";
      };
      mcmojave-cursor = pkgs.stdenv.mkDerivation {
        pname = "mcmojave-cursor";
        version = "1.0.0";
        src = mcmojave;
        installPhase = ''
          mkdir -p $out/share/icons
          cp -r dist $out/share/icons/McMojave
        '';
      };
    in {
      package = mcmojave-cursor;
      name = "McMojave";
      size = 20;
      # package = pkgs.nordzy-cursor-theme;
      # name = "Nordzy-cursors";
    };

    fonts = {
      sizes.terminal = 10;

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
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
  };
}
