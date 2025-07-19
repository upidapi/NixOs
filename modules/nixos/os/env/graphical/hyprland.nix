{
  config,
  my_lib,
  lib,
  inputs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.env.graphical.hyprland;
in {
  options.modules.nixos.os.env.graphical.hyprland =
    mkEnableOpt "enable system support for hyprland";

  imports = [
    inputs.hyprland.nixosModules.default
  ];

  config = mkIf cfg.enable {
    # environment.variables.nixos_ozone_wl = "1";

    # enable hyprland and required options
    programs.hyprland.enable = true;
  };
}
