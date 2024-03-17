{
  inputs,
  self,
  withSystem,
  lib,
  ...
}: let
  mkSystem = {
    name, # eg default
    system, # eg x86_64-linux
  }: {
    "${name}" = withSystem system (
      {
        inputs',
        self',
        ...
      }: let
        extra_args = {
          inherit inputs inputs' self self';
          my_lib = (import ./../lib) {lib = lib;};
        };
      in
        inputs.nixpkgs.lib.nixosSystem {
          system = system;

          specialArgs = extra_args;

          modules =
            [
              ./${name}/config.nix
              ./../modules/nixos
            ]
            ++ [
              # home manager
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager = {
                  extraSpecialArgs = extra_args;

                  useGlobalPkgs = true;
                  useUserPackages = true;

                  users."upidapi" = {...}: {
                    imports = [
                      ./${name}/home.nix
                      ./../modules/home
                    ];
                  };
                };
              }
            ];
        }
    );
  };
in {
  # you can // (or) multiple mkSystems
  flake.nixosConfigurations = (
    mkSystem {
      system = "x86_64-linux";
      name = "default";
    }
  );
}
