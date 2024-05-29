{
  config,
  my_lib,
  lib,
  inputs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.system.other.sops;
in {
  # might want to remove/disable the import when
  # thiss modules is disabled
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.modules.nixos.system.other.sops =
    mkEnableOpt "enables sops";

  config =
    mkIf cfg.enable {
    };
}
