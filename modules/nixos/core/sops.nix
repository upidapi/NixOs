{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.core;
in {
  options.modules.nixos.core =
    mkEnableOpt "enables sops";

  config = mkIf cfg.enable {

  };
}
