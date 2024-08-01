{
  pkgs,
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.virtualization.qemu;
in {
  options.modules.nixos.os.virtualization.qemu =
    mkEnableOpt
    "enables the qemu for running vm(s)";

  config.environment =
    mkIf cfg.enable {
    };
}
