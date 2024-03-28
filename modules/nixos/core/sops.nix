{
  config,
  my_lib,
  lib,
  inputs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.core.sops;
in {
  # might whant to remove/disable the import when 
  # thiss modules is disabled
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.modules.nixos.core.sops =
    mkEnableOpt "enables sops";

  config = mkIf cfg.enable {

  };
}
