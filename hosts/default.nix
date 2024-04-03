{
  inputs,
  self,
  withSystem,
  lib,
  ...
}: let
  mkUsers = {
    extra_args,
    profile,
    users,
    ...
  }: [
    inputs.home-manager.nixosModules.home-manager

    # normal nixos config
    ({pkgs, ...}: {
      modules.nixos.users = users;

      # todo: derrive this from "users"
      # (im too lazy to do this now)
      # for now it's defined in each config
      /*
         users.users = map-users (
        user-name: user-cfg: {
          isNormalUser = true;
          description = user-name;

          # make a cfg-editor group that makes it so that a user
          # can edit the config
          extraGroups = ["networkmanager" "wheel"];
          shell = pkgs.zsh;
          initialPassword = "1";
          # packages = with pkgs; [
          #   # firefox
          # ];
        }
      );
      */

      home-manager = {
        extraSpecialArgs = extra_args;

        useGlobalPkgs = true;
        useUserPackages = true;
        users =
          builtins.mapAttrs
          (
            user-name: _: {...}: {
              imports = [
                {
                  home.username = user-name;

                  home.homeDirectory = "/home/${user-name}";
                }

                inputs.impermanence.nixosModules.home-manager.impermanence
                ./../modules/home

                # todo: make is so that you can have multiple users
                # probably add a users/ where each sub file is a
                # user
                ./${profile}/home.nix
              ];

              # Let Home Manager install and manage itself.
              programs.home-manager.enable = true;
            }
          )
          users;
      };
    })
  ];

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
            ]
            ++ [
              # config
              ./../modules/nixos
              ./${name}/config.nix
            ]
            ++ mkUsers {
              inherit extra_args;
              profile = name;
              users = {
                "upidapi" = {};
              };
            };
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
    # mkSystem {
    #   system = "x86_64-linux";
    #   name = "raw-nixos";
    # } //
    # mkSystem {
    #   system = "x86_64-linux";
    #   name = "raw";
    # } //
    mkSystem {
      system = "x86_64-linux";
      name = "default";
    } # //
    # mkSystem {
    #   system = "x86_64-linux";
    #   name = "test";
    # }
  );
}
