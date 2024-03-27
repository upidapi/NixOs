{
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkOpt;
  inherit (lib) types;
in {
  imports = [
    ./gc.nix
    ./flakes.nix
    ./cachix.nix
    ./sops.nix
  ];
  
  # used by other modules
  options.modules.nixos.core = {
    nixos-cfg-path = mkOpt types.str null 
      "that absolute path of the nixos config";
  };
}
