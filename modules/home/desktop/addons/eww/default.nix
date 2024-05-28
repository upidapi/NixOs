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

  startEww = pkgs.writeShellScriptBin "start-eww-bar" ''
    monitors=$(
        hyprctl monitors -j | \
        python3 -c "import sys, json; print(len(json.load(sys.stdin)) - 1)"
    )

    for monitor in $(seq 0 "$monitors"); do
        eww open bar --arg "monitor=$monitor" --id "$monitor";
    done
  '';
in {
  options.modules.home.desktop.addons.eww =
    mkEnableOpt "enables eww";

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      exec-once = ["bash ${startEww}/bin/start-eww-bar"];
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
