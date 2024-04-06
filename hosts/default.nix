{
  inputs,
  self,
  withSystem,
  lib,
  ...
}: let
  # takes a list off attrs and uses func to derive
  # the value of each attr
  mapToAttrs = func: list:
    builtins.listToAttrs (
      builtins.map (
        attr: {
          name = attr;
          value = func attr;
        }
      )
      list
    );

  mkUser = profile: user-name: {...}: {
    imports = [
      inputs.hyprland.homeManagerModules.default

      {
        home.username = user-name;

        # only for testing
        # home.stateVersion = "23.11"
        home.homeDirectory = "/home/${user-name}";
      }

      ./../modules/home

      # todo: make is so that you can have multiple users
      # probably add a users/ where each sub file is a
      # user
      ./${profile}/home.nix
    ];

    # Let Home Man# ager install and manage itself.
    programs.home-manager.enable = true;
  };

  mkUsers = {
    extra_args,
    profile,
    users,
    ...
  }: [
    inputs.home-manager.nixosModules.home-manager

    # normal nixos config
    (
      {
        pkgs,
        config,
        ...
      }: {
        config = {
          home-manager = {
            extraSpecialArgs = extra_args;

            useGlobalPkgs = true;
            useUserPackages = true;
            users =
              mapToAttrs
              (mkUser profile)
              users;
          };
        };
      }
    )
  ];

  mkSystem = {
    name, # eg default
    system, # eg x86_64-linux
    users,
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
              inputs.hyprland.nixosModules.default
            ]
            ++ [
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
              inherit users;
            };
        }
    );
  };

  mkConfig = configs:
    builtins.foldl'
    (a: b: a // b)
    {}
    (
      builtins.map
      mkSystem
      configs
    );
in {
  flake.nixosConfigurations = mkConfig [
    {
      system = "x86_64-linux";
      users = ["upidapi"];
      name = "test";
    }
    {
      system = "x86_64-linux";
      name = "default";
      users = ["upidapi"];
    }
    {
      system = "x86_64-linux";
      name = "bare";
      users = ["upidapi"];
    }
  ];
}
