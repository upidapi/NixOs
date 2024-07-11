let
  inherit (builtins) attrValues concatLists map;

  # Users
  users = {
    upidapi = "ssh-ed25519"; # TODO: add upidpai user key
  };

  # Hosts
  machines = {
    full-installer-x86_64 = [];
    minimal-installer-x86_64 = [];
    upidapi-nix-laptop = [];
    upidapi-nix-pc = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAZGOYHhwBexxezYimuNmPqU2nh5dyJrmJLRvE3Nm/B upidapi@upidapi-nix-pc"];
  };

  # Shorthand aliases for various collections of host keys
  servers = concatLists (map (host: machines.${host}) []);
  workstations = concatLists (map (host: machines.${host}) ["upinix-pc"]); # TODO: "upinix-laptop"]);

  all = (attrValues users) ++ (attrValues machines);
in {
  inherit
    users
    machines
    servers
    workstations
    all
    ;
}
