{
  my_lib,
  lib,
  config,
  ...
}: let
  inherit (my_lib.opt) mkOpt;
  inherit (lib) types;
  cfg = config.modules.nixos.system.nix;
in {
  imports = [
    ./gc.nix
    ./flakes.nix
    ./cachix.nix
    ./nix-index.nix
  ];

  # used by other modules
  options.modules.nixos.system.nix = {
    cfg-path =
      mkOpt types.str null
      "that absolute path of the nixos config";
  };

  # TODO: look at auto-optimise-store = true;
  # TODO: more settings (eg https://github.com/ErrorNoInternet/configuration.nix/blob/1bcf2395470a3c48162160ec8d41146c06f50e86/nixos/common.nix#L82)

  config = {
    nix.settings.auto-optimise-store = true;
    environment.sessionVariables = {
      NIXOS_CONFIG_PATH = cfg.cfg-path;
    };
  };
}
