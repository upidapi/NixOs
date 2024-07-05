{
  imports = [
    (
      (import ./../lib/mk_hosts.nix)
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
          name = "full-installer-x86_64";
          disko = false; # cant have disko on a usb :)
        }
        {
          system = "x86_64-linux";
          name = "minimal-installer-x86_64";
          home-manager = false;
          disko = false;
        }
      ]
    )
  ];
}
