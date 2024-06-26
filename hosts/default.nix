{
  inputs,
  self,
  withSystem,
  lib,
  ...
}: let
  # takes a list of attrs and uses func to derive
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

      ./${profile}/users/${user-name}.nix
    ];

    # Let Home Man# ager install and manage itself.
    programs.home-manager.enable = true;
  };

  # gets the user names from the filenames in hosts/${profile}/.
  getUserNames = profile: let
    has-users = builtins.hasAttr "users" (
      builtins.readDir ./${profile}
    );
  in
    if !has-users
    then []
    else
      (
        builtins.map
        (
          user-file:
            if (lib.hasSuffix ".nix" user-file)
            then (lib.removeSuffix ".nix" user-file)
            else
              (
                builtins.throw
                ''The user file hosts/${profile}/${user-file} is not a .nix file''
              )
        )
        (builtins.attrNames (builtins.readDir ./${profile}/users))
      );

  # creates a home-manager user
  mkUsers = {
    extra_args,
    profile,
  }: [
    inputs.home-manager.nixosModules.home-manager

    {
      config = {
        home-manager = {
          extraSpecialArgs = extra_args;
          backupFileExtension = "hm-old";
          useGlobalPkgs = true;
          useUserPackages = true;
          users =
            mapToAttrs
            (mkUser profile)
            (getUserNames profile);
        };
      };
    }
  ];

  mkSystem = {
    hosts, # all hosts
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
              {
                modules.nixos.hosts = hosts;
                modules.nixos.host-name = name;

                environment.sessionVariables = {
                  FLAKE_PROFILE = name;
                };
              }

              # disko
              inputs.disko.nixosModules.default
              (import ./${name}/disko.nix)

              # Include the results of the hardware scan.
              ./${name}/hardware.nix

              # config
              ./../modules/nixos
              ./${name}/config.nix
            ]
            ++ (mkUsers {
              inherit extra_args;
              profile = name;
            });
        }
    );
  };

  mkConfig = configs: let
    hosts = (
      builtins.map
      (config: config.name)
      configs
    );
  in
    builtins.foldl'
    (a: b: a // b)
    {}
    (
      builtins.map
      (config: mkSystem (config // {hosts = hosts;}))
      configs
    );
in {
  /*

  To add a new profile first add a attrset with the system info
    system: the type of system

    name: the profile name
      i.e to create the profile you'll have to use
        path-to-flakes#${name}

  Then add a new directory in ./hosts/

  In that directory the following things should exist:
    config.nix
      The nixos config file
      It is provided with the nixos modules (./module/nixos)

      Note: you can access the home-manager config through
        config.home-manager."${user-name}"

    hardware.nix
      A file that defines hardware specific stuff
      Should probably be generated by:
        (nixos-generate-config \
          --no-filesystems \
          --show-hardware-config
        ) > hosts/${name of profile}/hardware.nix

    disko.nix
      This will be passed to disko to partition the disks

    users/
      This directory contains all users (home-manager config)

      This dir can be skipped or left empty. In that case
      home-manager won't be added

      users/${user-name}.nix
        This would create a user with the user-name: ${user-name}

        Each file is a home-manager config for said user

        They are all provided with my home-manager modules
          i.e ./../modules/home

        Note:
          home.username and home.userDirectory are set automatically
  */

  flake.nixosConfigurations = mkConfig [
    # this is the only part that you should change
    {
      system = "x86_64-linux";
      name = "upinix-pc";
    }
    {
      system = "x86_64-linux";
      name = "upinix-laptop";
    }
  ];
}
