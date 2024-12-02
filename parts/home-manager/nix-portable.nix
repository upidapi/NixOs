# install my hm config on a system without nix nor root
/*
username="drs_temp_mk2416"

# set -ex
cd ~

# Download nix-portable
curl \
  -L "https://github.com/DavHau/nix-portable/releases/latest/download/nix-portable-$(uname -m)" \
  > ./nix-portable

# Generate symlinks for seamless integration
chmod +x nix-portable
ln -s nix-portable nix

./nix-portable nix-shell -p home-manager nix zsh
home-manager switch -b old --flake "github:upidapi/NixOs#$username"
zsh

# for some reason yo have to use "zsh $(which --cmd--)" to run a command that uses exec
# since running scripts with exec breaks bash
r() {zsh "${which "$1"}"}

alias nvim="zsh $(which nvim)"
alias man="zsh $(which man)"
*/
# should also work for standalone install
{
  inputs,
  self,
  withSystem,
  lib,
  ...
}: let
  mkNixPortableHomes = configs:
    builtins.mapAttrs (
      user-name: system:
        withSystem system (
          {
            pkgs,
            inputs',
            self',
            ...
          }: let
            extra_args = {
              inherit inputs inputs' self self';

              my_lib = (import ./parts/lib) {inherit lib;};
              keys = (import ./parts/keys.nix) {inherit lib;};
              osConfig = {
                modules.nixos = {
                  nix.cfg-path = "~/persist/NixOs";
                  hardware.monitors = [];
                };
              };
            };
          in
            inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;

              modules = [
                # inputs.hyprland.homeManagerModules.default

                {
                  home = {
                    username = user-name;

                    sessionVariables.PATH = "$HOME/.nix-profile/bin:$PATH";

                    packages = [
                      pkgs.nerd-fonts.symbols-only
                    ];
                  };
                }

                ./homes/${user-name}.nix
              ];

              extraSpecialArgs = extra_args;
            }
        )
    )
    configs;
in {
  flake.homeConfigurations = mkNixPortableHomes {
    "drs_temp_mk2416" = "x86_64-linux";
  };
}
