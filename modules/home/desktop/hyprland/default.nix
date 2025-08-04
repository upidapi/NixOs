{
  config,
  mlib,
  lib,
  inputs,
  pkgs,
  osConfig,
  ...
}: let
  inherit (mlib) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.desktop.hyprland;
in {
  imports = [
    ./config.nix
    ./binds.nix
    ./monitors.nix
    inputs.hyprland.homeManagerModules.default
  ];

  options.modules.home.desktop.hyprland =
    mkEnableOpt "enables hyperland, a wayland tiling manager";

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.enable || (cfg.enable || osConfig.programs.hyprland.enable);
        message = "You have to enable the nixos packages.hyprland option for hyprland properly work";
      }
    ];
    home.packages = with pkgs; [
      brightnessctl
      hyprpicker
      grimblast
    ];

    wayland.windowManager.hyprland = {
      # Whether to enable Hyprland wayland compositor
      enable = true;
      # The hyprland package to use
      package = pkgs.hyprland;
      # Whether to enable XWayland
      xwayland.enable = true;

      # Optional
      # Whether to enable hyprland-session.target on hyprland startup
      systemd.enable = true;
    };
    # wayland.windowManager.hyprland.enable = true;
  };
}
