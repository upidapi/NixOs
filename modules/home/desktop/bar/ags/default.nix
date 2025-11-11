{
  config,
  mlib,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (mlib) mkEnableOpt;
  inherit (mlib.misc) mapStylixColors;
  inherit (lib) mkIf;
  cfg = config.modules.home.desktop.bar.ags;
in {
  options.modules.home.desktop.bar.ags =
    mkEnableOpt "enables ags, used to create a bar";

  # is this stil an issue?
  # breaks on suspend, the hyprland ref is null (only sometimes)

  # Breaks when this is run
  # Previously grimblast ran that but i removed that part
  # hyprctl output create headless "virtualDisplayName" >/dev/null
  # hyprctl output remove "virtualDisplayName" >/dev/null

  imports = [
    # inputs.ags.homeManagerModules.default
  ];

  config = let
    pkg = pkgs.ags.override {
      extraPackages = with pkgs;
        [
          bun
        ]
        ++ (with inputs.ags.packages.${pkgs.system}; [
          # most of these are unecesary
          apps
          auth
          battery
          bluetooth
          hyprland
          mpris
          network
          notifd
          powerprofiles
          tray
          wireplumber
          # inputs.astal.packages.${pkgs.system}.default
        ]);
      # astal3 = cfg.astal.gtk3Package;
      # astal-io = cfg.astal.ioPackage;
      # agsJsPackage = "${config.home.homeDirectory}/.local";
    };
  in
    mkIf cfg.enable {
      # doesnt work for some reason
      # nixpkgs.overlays = [
      #   (_: super: {
      #     wrapGAppsHook = super.wrapGAppsHook3;
      #   })
      # ];

      wayland.windowManager.hyprland.settings = {
        exec-once = ["ags run"];
      };

      home.packages = with pkgs; [
        pkg
        bun
        sassc
      ];

      # don't forget to generate the types in the correct dir
      # :(
      #
      # nix shell github:aylur/ags#agsFull -c bash -c "ags types -d ./"
      # nix shell nixpkgs#inotify-tools github:aylur/ags#agsFull

      # programs.ags = {
      #   enable = true;
      #   # configDir = ./.;
      #   # https://github.com/DaRacci/nix-config/blob/42f3b6ea528bcf614f08201e74c4e9e3b9db80ef/home/racci/features/desktop/hyprland/ags.nix
      #   extraPackages = with pkgs;
      #     [
      #       bun
      #     ]
      #     ++ (with inputs.ags.packages.${pkgs.system}; [
      #       # most of these are unecesary
      #       apps
      #       auth
      #       battery
      #       bluetooth
      #       hyprland
      #       mpris
      #       network
      #       notifd
      #       powerprofiles
      #       tray
      #       wireplumber
      #       # inputs.astal.packages.${pkgs.system}.default
      #     ]);
      # };

      # This is so jank
      # - some guy on github solving the same problem
      home.file = {
        ".config/ags" = {
          recursive = true;
          source = ./src;
        };
        ".config/ags/colors.scss".text =
          mapStylixColors config "\n"
          (color: name: "\$${name}: #${color};");
      };
    };
}
