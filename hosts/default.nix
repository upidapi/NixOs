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
              # disko
              inputs.disko.nixosModules.default
              (import ./${name}/disko.nix)
            ] ++ [
              # config
              ./../modules/nixos
              ./${name}/config.nix
            ] ++ [
              # home manager
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager = {
                  extraSpecialArgs = extra_args;

                  useGlobalPkgs = true;
                  useUserPackages = true;

                  users."upidapi" = {...}: {
                    imports = [
                      inputs.impermanence.nixosModules.home-manager.impermanence
                      ./../modules/home
                      ./${name}/home.nix
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
  # flake.nixosConfigurations = (
  #   mkSystem {
  #     system = "x86_64-linux";
  #     name = "default";
  #   }
  # );
  flake.nixosConfigurations = (
    mkSystem {
      system = "x86_64-linux";
      name = "default";
    } # //
    # mkSystem {
    #   system = "x86_64-linux";
    #   name = "raw";
    # }
  );

}
