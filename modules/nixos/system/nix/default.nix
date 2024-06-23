{
  my_lib,
  lib,
  config,
  inputs,
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

  # TODO: look at ca-derivations

  config = {
    nix = {
      channel.enable = false;
      nixPath = [
        # Point to a stable path so system updates immediately update
        "nixpkgs=/run/current-system/nixpkgs"
      ];

      # Pinning flake registry entries, to avoid unpredictable cache invalidation and
      # corresponding large downloads
      registry = {
        nixpkgs.flake = inputs.nixpkgs;
        nixfiles.flake = inputs.self;
      };

      settings = {
        flake-registry = "";

        auto-optimise-store = true;

        log-lines = 500;
        show-trace = true;
      };
    };

    environment.sessionVariables = {
      NIXOS_CONFIG_PATH = cfg.cfg-path;
    };
  };
}
