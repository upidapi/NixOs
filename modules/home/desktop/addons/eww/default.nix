{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.desktop.addons.eww;
in {
  options.modules.home.desktop.addons.eww =
    mkEnableOpt "enables eww";

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      exec-once = ["bash ${./start.sh}"];
    };

    home.packages = with pkgs; [
      eww
    ];

    programs.eww = {
      enable = true;
      configDir = ./config;
    };
  };

  # to run exec: (in this dir)
  # eww open -c ./ bar --arg monitor_id=2
}
