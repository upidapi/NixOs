{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    poetry2nix.url = "github:nix-community/poetry2nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        # systems for which you want to build the `perSystem` attributes
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem = {
        pkgs,
        system,
        self,
        ...
      }: let
        inherit
          (inputs.poetry2nix.lib.mkPoetry2Nix {
            inherit pkgs;
          })
          mkPoetryApplication
          ;
      in {
        packages.default = mkPoetryApplication {
          projectDir = self;
          nativeBuildInputs = [
            pkgs.makeWrapper
          ];

          propogatedBuildInputs = [
            pkgs.util-linux
          ];

          postInstall = ''
            wrapProgram "$out/bin/default" \
              --prefix PATH : ${pkgs.lib.makeBinPath [
              pkgs.util-linux
            ]}
          '';
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [self.packages.${system}.default];
          packages = [
            pkgs.poetry
          ];
        };
      };
    };
}
