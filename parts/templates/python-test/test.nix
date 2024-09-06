{
  description = "Application packaged using poetry2nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    poetry2nix,
  }:
    {
      # Nixpkgs overlay providing the application
      overlay = nixpkgs.lib.composeManyExtensions [
        poetry2nix.overlay
        (final: prev: {
          # The application
          myapp = prev.poetry2nix.mkPoetryApplication {
            projectDir = ./.;
          };
          # The env
          myenv = prev.poetry2nix.mkPoetryEnv {
            projectDir = ./.;
          };

          poetry2nix = prev.poetry2nix.overrideScope' (p2nixfinal: p2nixprev: {
            # pyfinal & pyprev refers to python packages
            defaultPoetryOverrides = p2nixprev.defaultPoetryOverrides.extend (
              pyfinal: pyprev: {
                ### dodge infinite recursion ###
                setuptools = prev.python310Packages.setuptools.override {
                  inherit
                    (pyfinal)
                    bootstrapped-pip
                    pipInstallHook
                    setuptoolsBuildHook
                    ;
                };

                setuptools-scm = prev.python310Packages.setuptools-scm.override {
                  inherit
                    (pyfinal)
                    packaging
                    typing-extensions
                    tomli
                    setuptools
                    ;
                };

                pip = prev.python310Packages.pip.override {
                  inherit
                    (pyfinal)
                    bootstrapped-pip
                    mock
                    scripttest
                    virtualenv
                    pretend
                    pytest
                    pip-tools
                    ;
                };
              }
            );
          });
        })
      ];
    }
    // (flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [self.overlay];
      };
    in {
      packages.default = pkgs.myapp;
      packages.myapp = pkgs.myapp;
      packages.myenv = pkgs.myenv;

      devShells.dev = pkgs.mkShell {
        buildInputs = with pkgs; [
          #(python310.withPackages (ps: with ps; [ poetry ]))
          pkgs.myenv
        ];
      };

      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          (python310.withPackages (ps: with ps; [poetry]))
        ];
      };
    }));
}
