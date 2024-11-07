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
  #!/bin/env bash

  # to run this manually use
  ags --quit;

  cd || return
  color_cfg="$(realpath .config/ags/colors.scss)"
  mkdir .config/ags-dbg

  ags_src="$NIXOS_CONFIG_PATH/modules/home/desktop/addons/bar/ags/src"
  cp -r "$ags_src"/* .config/ags-dbg
  cp "$color_cfg" .config/ags-dbg/colors.scss

  ags -c ./.config/ags-dbg/config.js
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
}
