{
  config,
  my_lib,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.desktop.addons.ags;
in {
  options.modules.home.desktop.addons.ags =
    mkEnableOpt "enables ags, used to create a bar";

  imports = [
    inputs.ags.homeManagerModules.default
  ];

  /*
  # to run this manually use
  ags --quit;
  ags -c /persist/nixos/modules/home/desktop/addons/ags/config.js
  */
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      exec-once = ["bash ags -c \"${./config.js}\""];
    };

    home.packages = with pkgs; [
      bun
    ];

    programs.ags = {
      enable = true;
      configDir = ./.;
      extraPackages = with pkgs; [
        bun
      ];
    };
  };

  # to run exec: (in this dir)
  # eww open -c ./ bar --arg monitor_id=2
}
