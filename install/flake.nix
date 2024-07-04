{
  description = "Minimal NixOS configuration for bootstrapping systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      /*
      imports = [
        ({
          inputs,
          self,
          withSystem,
          lib,
          ...
        }: let
          mkConfig =
            ((import ./../lib/hosts.nix) {
              # TODO: for some reason it doesn't work if i just directly pass it
              inherit inputs;
              inherit self;
              inherit withSystem;
              inherit lib;
            })
            .mkConfig;
        in {
          flake.nixosConfigurations = (mkConfig ./iso) [
            # this is the only part that  you should change
            {
              system = "x86_64-linux";
              name = "nixos-installer-x86_64";
            }
          ];
        })
      ];
      */
      imports = [
        (
          (import ./../lib/mk_hosts.nix)
          ./iso
          [
            {
              system = "x86_64-linux";
              name = "nixos-installer-x86_64";
              home-manager = false;
              disko = false; # TODO: ?
            }
          ]
        )
      ];

      systems = [
        # systems for which you want to build the `perSystem` attributes
        "x86_64-linux"
        # ...
      ];
    };
}
