{...}: {
  imports = [
    ./args.nix
    ./install
    ./isos
    ./npins
    ./pkgs
    ./shells
    ./templates
    ./home-manager
  ];

  # ./lib and ./keys is imported in ./args.nix
  # (or actually in ./lib/mk_hosts.nix for now)
}
