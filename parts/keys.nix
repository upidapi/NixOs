{lib, ...}: let
  inherit (builtins) elem;
  inherit (lib.attrsets) filterAttrs;

  # Users
  users = {
    upidapi = "ssh-ed25519"; # TODO: add upidapi user key
  };
  
  # TODO: possibly assert that all machines (and users) are here?

  # Hosts
  machines = {
    full-installer-x86_64 = [];
    minimal-installer-x86_64 = [];
    upidapi-nix-laptop = [];
    upidapi-nix-pc = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAZGOYHhwBexxezYimuNmPqU2nh5dyJrmJLRvE3Nm/B"
      /*
      upidapi@upidapi-nix-pc"
      */
    ];
  };

  filterAttrsList = inp: white_list: (filterAttrs (x: elem white_list x) inp);
  # Shorthand aliases for various collections of host keys

  servers = filterAttrsList machines [];
  workstations = filterAttrsList machines ["upidapi-nix-pc"]; # TODO: "upinix-laptop"]);
  # all = (attrValues users) ++ (attrValues machines);
in {
  inherit
    users
    machines
    servers
    workstations
    # all
    ;
}
