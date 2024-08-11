# taken from notashelf
{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.virtualization.virt-manager;
in {
  options.modules.nixos.os.virtualization.virt-manager =
    mkEnableOpt "enable virt-manager";

  config = mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
  };
}
