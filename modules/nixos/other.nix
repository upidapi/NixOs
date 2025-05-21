{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.other;
in {
  options.modules.nixos.other =
    mkEnableOpt "enables config that i've not found a place for";

  config = mkIf cfg.enable {
    # for bios updates
    services.fwupd = enable;

    # maybe make some gnome things work
    programs.dconf.enable = true;
    environment.systemPackages = [
      pkgs.adwaita-icon-theme
    ];
  };
}
