{
  description = "";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    flake-parts,
    # self,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        # systems for which you want to build the `perSystem` attributes
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem = {pkgs, ...}: let
      in {
        devShells.default = pkgs.mkShell {
          name = "";
          # inputsFrom = [mainPackage];
          packages = with pkgs; [
          ];
        };
      };
    };
}
