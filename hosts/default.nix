{
  imports = [
    (
      (import ./../parts/lib/mk_hosts.nix)
      ./.
      [
        {
          # do we need to set system?
          system = "x86_64-linux";
          name = "upinix-pc";
        }
        {
          system = "x86_64-linux";
          name = "upinix-laptop";
        }
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
