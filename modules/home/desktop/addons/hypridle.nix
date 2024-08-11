# based on / taken from
# https://github.com/notohh/snowflake/blob/master/home/wayland/programs/hyprlock.nix
{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.desktop.addons.hypridle;
in {
  options.modules.home.desktop.addons.hypridle =
    mkEnableOpt "enables hypridle, an idle listener for hyprland";

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      exec-once = ["hypridle"];
    };

    home.packages = [pkgs.hypridle];

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          # to avoid having to press a key twice to turn on the display.
          after_sleep_cmd = "hyprctl dispatch dpms on";
          # lock before suspend.
          before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
          # avoid starting multiple hyprlock instances.
          lock_cmd = "pidof hyprlock || hyprlock";
          # whether to ignore dbus-sent idle inhibit events (e.g. from firefox)
          ignore_dbus_inhibit = false;
        };

        listener = [
          {
            timeout = 300;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 330;
            on-timeout = "hyprlock";
          }
        ];
      };
    };
  };
}