{
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
  flake.nixosConfigurations = (mkConfig ./.) [
    # this is the only part that  you should change
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
