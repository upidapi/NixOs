{
  pkgs,
  config,
  mlib,
  lib,
  ...
}: let
  inherit (mlib) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.misc.programs.eza;
in {
  options.modules.nixos.misc.programs.eza =
    mkEnableOpt
    "enables eza";

  config.environment = mkIf cfg.enable {
    systemPackages = [
      pkgs.eza
    ];
  };
}
