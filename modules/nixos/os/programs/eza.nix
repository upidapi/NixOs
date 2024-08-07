{
  pkgs,
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
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
