{...}: {
  imports = [
    ./args.nix
    ./shells
    ./pkgs
    ./install
    ./iso-images.nix
    # ./templates
  ];
}
