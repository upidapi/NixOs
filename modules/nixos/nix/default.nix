{
  my_lib,
  lib,
  config,
  ...
}: let
  inherit (my_lib.opt) mkOpt;
  inherit (lib) types;
  cfg = config.modules.nixos.nix;
in {
  imports = [
    ./gc.nix
    ./flakes.nix
    ./cachix.nix
    ./nix-index.nix
    ./misc.nix
  ];

  # used by other modules
  options.modules.nixos.nix = {
    cfg-path =
      mkOpt types.str null
      "that absolute path of the nixos config";
  };

  config = {
    environment.sessionVariables = {
      NIXOS_CONFIG_PATH = cfg.cfg-path;
    };
  };
}
