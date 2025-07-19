/*
{
  imports = [
    (
      (import ./../parts/lib/mk_hosts.nix)
      ./.
      [
        {
          system = "x86_64-linux";
          name = "full-installer";
          disko = false; # cant have disko on a usb :)
        }
        {
          system = "x86_64-linux";
          name = "minimal-installer";
          home-manager = false;
          disko = false;
        }
        {
          system = "x86_64-linux";
          name = "test-installer";
          home-manager = false;
          disko = false;
        }
      ]
    )
  ];
}
*/
{
  self,
  withSystem, # has to be explicit since the module system is lazy
  ...
} @ args: let
  mkHosts = (import "${self}/parts/lib/mk_hosts.nix") ./. args;
  inherit (mkHosts) foldMapSystems mkSystem;
in {
  flake.nixosConfigurations = foldMapSystems mkSystem [
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
