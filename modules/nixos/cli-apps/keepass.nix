{
  pkgs,
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.cli-apps.keepass;
in {
  options.modules.nixos.cli-apps.keepass =
    mkEnableOpt "enables keepass xc";

  config.environment = mkIf cfg.enable {
    systemPackages = [
      pkgs.keepassxc
    ];
  };
}
