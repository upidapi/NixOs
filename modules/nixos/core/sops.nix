{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.core.sops;
in {
  options.modules.nixos.core.sops =
    mkEnableOpt "enables sops";

  config = mkIf cfg.enable {

  };
}
