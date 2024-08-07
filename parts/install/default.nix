{
  perSystem = {
    pkgs,
    # self,
    ...
  }: {
    # you can run the installer (run install.sh) with the following command
    # sudo nix --experimental-features "nix-command flakes" run github:upidapi/nixos
    packages.install =
      pkgs.writers.writePython3
      "nixos-installer"
      {flakeIgnore = ["E302" "E303" "E501" "W391" "W293" "W291" "E128" "E124"];}
      (builtins.readFile ./install.py);
  };
}
