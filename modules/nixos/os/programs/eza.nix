{
  pkgs,
  config,
  mlib,
  lib,
  ...
}: let
  inherit (mlib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.programs.eza;
in {
  options.modules.nixos.os.programs.eza =
    mkEnableOpt
    "enables eza";

  config.environment = mkIf cfg.enable {
    systemPackages = [
      pkgs.eza
    ];
  };
}
