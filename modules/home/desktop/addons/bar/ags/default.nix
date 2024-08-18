{
  config,
  my_lib,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (my_lib.misc) mapStylixColors;
  inherit (lib) mkIf;
  cfg = config.modules.home.desktop.addons.bar.ags;
in {
  options.modules.home.desktop.addons.bar.ags =
    mkEnableOpt "enables ags, used to create a bar";

  imports = [
    inputs.ags.homeManagerModules.default
  ];

  /*
  # to run this manually use
  ags --quit;
  ags -c /persist/nixos/modules/home/desktop/addons/ags/config.js
  */

  # TODO: use systemd-inhibit to inhibit idle with a switch

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      exec-once = ["ags"];
    };

    home.packages = with pkgs; [
      bun
      sassc
    ];

    programs.ags = {
      enable = true;
      # configDir = ./.;
      extraPackages = with pkgs; [
        bun
      ];
    };

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

  # to run exec: (in this dir)
  # eww open -c ./ bar --arg monitor_id=2
}
