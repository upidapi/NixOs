{
  config,
  my_lib,
  lib,
  inputs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.system.misc.noshell;
in {
  # might want to remove/disable the import when
  # this modules is disabled
  imports = [
    inputs.noshell.nixosModules.default
  ];

  options.modules.nixos.system.misc.noshell =
    mkEnableOpt "enables noshell, used to set shell with home manager";

  config = mkIf cfg.enable {
    programs.noshell.enable = true;
  };
}
