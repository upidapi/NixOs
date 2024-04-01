{
  config,
  my_lib,
  lib,
  inputs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.desktop.hyprland;
in {
  imports = [
    ./config.nix
    # TODO: does this fix connecting a disply to the motherbord?
    # inputs.hyprland.homeManagerModules.default
  ];

  options.modules.home.desktop.hyprland =
    mkEnableOpt "enables hyperland, a wayland tiling manager";

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.enable = true;
  };
}
