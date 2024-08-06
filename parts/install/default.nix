{
  perSystem = {
    pkgs,
    # self,
    ...
  }: let
    installerPkg =
      pkgs.writers.writePython3Bin
      "nixos-installer"
      {}
      (builtins.readFile ./install.py);
  in {
    # you can run the installer (run install.sh) with the following command
    # sudo nix --experimental-features "nix-command flakes" run github:upidapi/nixos

    apps.install = {
      type = "app";
      program = "${installerPkg}/bin/nixos-installer";
    };
  };
}
