{
  config,
  mlib,
  lib,
  inputs,
  ...
}: let
  inherit (mlib) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.misc.noshell;
in {
  imports = [
    inputs.noshell.nixosModules.default
  ];

  options.modules.nixos.os.misc.noshell =
    mkEnableOpt "enables noshell, used to set shell with home manager";

  config = mkIf cfg.enable {
    programs.noshell.enable = true;
  };
}
