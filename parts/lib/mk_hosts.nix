/*
To add a new profile first add a attrset with the system info
  system: the type of system

  name: the profile name
    i.e to create the profile you'll have to use
      path-to-flakes#${name}

    will be used as the name which will eg
      set the network name to that

  home-manager: disable / enable home-manager
    default: enable

Then add a new directory in ${root_dir}/hosts

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

  users/ (unless home-manager is set to false)
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
host_dir: {
  inputs,
  self,
  withSystem,
  lib,
  ...
}: rec {
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
      {
        home.username = user-name;

        # only for testing
        # home.stateVersion = "23.11"

        home.homeDirectory = "/home/${user-name}";
      }

      ./../../modules/home

      "${host_dir}/${profile}/users/${user-name}.nix"
    ];

    # Let home manager install and manage itself.
    programs.home-manager.enable = true;
  };

  # gets the user names from the filenames in hosts/${profile}/.
  getUserNames = profile: let
    has-users = builtins.hasAttr "users" (
      builtins.readDir "${host_dir}/${profile}"
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
                ''The user file ${host_dir}/${profile}/${user-file} is not a .nix file''
              )
        )
        (builtins.attrNames (builtins.readDir "${host_dir}/${profile}/users"))
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

  mkListIf = cond: thing:
    if cond
    then thing
    else [];

  mkSystem = {
    name, # eg default
    system, # eg x86_64-linux
    home-manager ? true,
    disko ? true,
    configs,
  }: {
    "${name}" = withSystem system (
      {
        inputs',
        self',
        ...
      }: let
        hosts =
          builtins.map
          (config: config.name)
          configs;

        extra_args = {
          inherit inputs inputs' self self';

          my_lib = (import ./../lib) {inherit lib;};
          keys = (import ./../keys.nix) {inherit lib;};
        };
      in
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = extra_args;

          modules =
            [
              {
                modules.nixos.meta = {
                  inherit hosts;
                  host-name = name;
                };

                environment.sessionVariables = {
                  FLAKE_PROFILE = name;
                };
              }

              # Include the results of the hardware scan.
              "${host_dir}/${name}/hardware.nix"

              # config
              ./../../modules/nixos
              "${host_dir}/${name}/config.nix"
            ]
            ++ (
              mkListIf disko [
                inputs.disko.nixosModules.default
                "${host_dir}/${name}/disko.nix"
              ]
            )
            ++ (
              mkListIf home-manager (mkUsers {
                inherit extra_args;
                profile = name;
              })
            );
        }
    );
  };
  foldMapSystems = f: list:
    builtins.foldl'
    (a: b: a // b)
    {}
    (builtins.map (a: f (a // {configs = list;})) list);
}
