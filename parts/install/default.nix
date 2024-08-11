{
  perSystem = {
    pkgs,
    # self,
    ...
  }: let
    installerPkg =
      pkgs.writers.writePython3Bin
      "nixos-install-wizard"
      {flakeIgnore = ["E302" "E303" "E501" "W391" "W293" "W291" "E128" "E124"];}
      (builtins.readFile ./install-waizard.py);
  in {
    # you can run the installer (run install.sh) with the following command
    # nix --experimental-features "nix-command flakes" run github:upidapi/nixos#install-wizard
    # you can add args by adding -- before them

    apps.install-wizard = {
      type = "app";
      program = "${installerPkg}/bin/nixos-install-wizard";
    };
  };
}
# TODO: bootstraping secrets
#  figure out how to establish install / continued trust
/*
load the secrets/infra.yaml
decrypt with admin key (+ passphrase?)

get the host/\${host name} key (and possibly the admin key)
    generate the age key(s) from those
    place the file in /persist/sops-nix-key.txt
    fix perms

------done by nix-sops------
this file will be used to decrypt everything for the host
    including user secrets

user secrets will be used to create the home envs
*/
# TODO: remote install
/*
nixos-anywhere

https://github.com/EmergentMind/nix-config
https://www.youtube.com/watch?v=4snnV3hdz7g
*/

