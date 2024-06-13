{
  config,
  my_lib,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (my_lib.opt) mkenableopt;
  inherit (lib) mkif;
  cfg = config.modules.home.desktop.addons.eww;
in {
  options.modules.home.desktop.addons.eww =
    mkenableopt "enables eww";

  imports = [inputs.ags.homeManagerModules.default];
  config = mkif cfg.enable {
    wayland.windowmanager.hyprland.settings = {
      exec-once = ["bash /bin/start-eww-bar"];
    };

    home.packages = with pkgs; [
      bun
    ];

    programs.ags = {
      enable = true;
      configdir = ./.;
      extraPackages = with pkgs; [
        bun
      ];
    };
  };

  # to run exec: (in this dir)
  # eww open -c ./ bar --arg monitor_id=2
}
