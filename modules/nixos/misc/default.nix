{
  imports = [
    ./steam.nix
    ./dotnet.nix
    ./nix.nix
    ./flatpak.nix

    # cant be imported due to how the iso stuff is set up
    # (options are in imports from nixpkgs)
    # ./iso.nix
  ];
}
