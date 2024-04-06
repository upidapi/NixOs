{
  lib,
  my_lib, 
  ...
}: let 
  inherit (lib) types;
  inherit (my_lib.opts) mkOpt;
in {
  imports = [
    ./apps
    ./cli-apps
    ./desktop
    ./hardware
    ./nix
    ./other
    ./system
  ];

  options.modules.nixos.host-name = 
      mkOpt types.str null
      "the name of the device";
}
