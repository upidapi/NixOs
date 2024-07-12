{
  my_lib,
  config,
  inputs,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.nix.misc;
in {
  imports = [
    ./gc.nix
    ./flakes.nix
    ./cachix.nix
    ./nix-index.nix
  ];

  # used by other modules
  options.modules.nixos.nix.misc = mkEnableOpt "enables various nix things";

  # TODO: look at ca-derivations
  # TODO: look at misterios templates

  config.nix = mkIf cfg.enable {
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
}
