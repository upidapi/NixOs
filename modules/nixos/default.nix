{
  lib,
  my_lib,
  ...
}: let
  inherit (lib) types;
  inherit (my_lib.opt) mkOpt;
in {
  imports = [
    ./apps
    ./cli-apps
    ./tools
    ./desktop
    ./hardware
    ./system
    ./suites
    ./home-tunnel.nix
    ./other.nix
  ];

  options.modules.nixos.host-name =
    mkOpt types.str null
    "the name of the device";
}
