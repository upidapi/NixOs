# based on / taken from
# https://github.com/notohh/snowflake/blob/master/home/wayland/programs/hyprlock.nix
{
  osConfig,
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf removePrefix;
  cfg = config.modules.home.desktop.addons.hyprlock;
in {
  options.modules.home.desktop.addons.hyprlock =
    mkEnableOpt "enables hyprlock, a relogin screen for hyprland";

  config = mkIf cfg.enable {
    home.packages = [pkgs.hyprlock];

    stylix.targets.hyprlock.enable = false;

    programs.hyprlock = let
      monitorCfg = osConfig.modules.nixos.hardware.monitors;
      fmtDesc = name: removePrefix "desc:" name;
      primary = fmtDesc monitorCfg.primaryMonitor;
    in {
      enable = true;
      settings = {
        background =
          builtins.map
          (monitor: {
            monitor = fmtDesc monitor.name;
            path = "${./wallpaper/wallpapers/simple-tokyo-night.png}";
            blur_passes = 3;
            blur_size = 4;
            brightness = 0.5;
          })
          (
            builtins.filter
            (m: m.enabled)
            (builtins.attrValues monitorCfg.monitors)
          );
        general = {
          grace = 5;
          disable_loading_bar = false;
          hide_cursor = false;
          no_fade_in = false;
        };
        input-field = [
          {
            monitor = primary;
            size = "350, 50";
            outline_thickness = 2;
            outer_color = "rgb(f7768e)";
            inner_color = "rgb(1a1b26)";
            font_color = "rgb(c0caf5)";
            fail_color = "rgb(f7768e)";
            fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
            check_color = "rgb(ff9e64)";
            swap_font_color = false;
            placeholder_text = ''
              <i><span foreground="##c0caf5">Password...</span></i>
            '';
            fade_on_empty = false;
            dots_spacing = 0.5;
            dots_center = true;
            shadow_passes = 3;
            shadow_size = 1;
            shadow_color = "rgba(00000099)";
            shadow_boost = 1.0;
          }
        ];
        label = [
          {
            monitor = primary;
            text = ''
              Hi, <i><span foreground="##f7768e">$USER</span></i>
            '';
            color = "rgb(c0caf5)";
            valign = "center";
            halign = "center";
            shadow_passes = 3;
            shadow_size = 1;
            shadow_color = "rgba(00000099)";
            shadow_boost = 1.0;
          }
          {
            monitor = primary;
            text = "$TIME";
            color = "rgb(c0caf5)";
            position = "0, 120";
            valign = "center";
            halign = "center";
            shadow_passes = 3;
            shadow_size = 1;
            shadow_color = "rgba(00000099)";
            shadow_boost = 0.6;
          }
        ];
      };
    };
  };
}
