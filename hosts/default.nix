{
  imports = [
    (
      (import ./../lib/mk_hosts.nix)
      ./.
      [
        {
          system = "x86_64-linux";
          name = "upinix-pc";
        }
        {
          system = "x86_64-linux";
          name = "upinix-laptop";
        }
        {
          system = "x86_64-linux";
          name = "nixos-installer-x86_64";
          home-manager = false;
          disko = false; # TODO: ?
        }
      ]
    )
  ];
}
