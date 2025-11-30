{
  imports = [
    ./boot
    ./programs
    ./services
    ./nix.nix
    ./nix-ld.nix
    ./flatpak.nix
    ./impermanence.nix
    ./prelockd.nix
    ./sops.nix

    # cant be imported due to how the iso stuff is set up
    # (options are in imports from nixpkgs)
    # ./iso.nix
  ];
}
