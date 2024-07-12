{
  config,
  my_lib,
  lib,
  inputs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.desktop.hyprland;
in {
  options.modules.nixos.os.desktop.hyprland =
    mkEnableOpt "add hyprland";

  imports = [
    inputs.hyprland.nixosModules.default
  ];

  config = mkIf cfg.enable {
    # environment.variables.NIXOS_OZONE_WL = "1";

    # enable hyprland and required options
    programs.hyprland.enable = true;
  };
}
