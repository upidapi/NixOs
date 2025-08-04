{
  mlib,
  config,
  inputs,
  lib,
  ...
}: let
  inherit (mlib) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.nix.misc;
in {
  # used by other modules
  options.modules.nixos.nix.misc = mkEnableOpt "enables various nix things";

  config = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in
    mkIf cfg.enable {
      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      nix = {
        channel.enable = false;
        /*
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
        */
        # Opinionated: make flake registry and nix path match flake inputs
        registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
        nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

        settings = {
          # disable global registry
          flake-registry = "";

          auto-optimise-store = true;

          # ALL THE LOGS
          log-lines = 500;
          show-trace = true;

          nix-path = config.nix.nixPath;

          # content addressed derivations
          experimental-features = [
            "ca-derivations"
          ];
        };
      };
    };
}
