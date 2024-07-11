{
  lib,
  my_lib,
  config,
  ...
}: let
  inherit (lib) types;
  inherit (my_lib.opt) mkOpt;
  cfg = config.modules.nixos;
in {
  imports = [
    ./apps
    ./cli-apps
    ./desktop
    ./hardware
    ./system
    ./suites
    ./other.nix
  ];

  options.modules.nixos = {
    hosts =
      mkOpt (types.listOf types.str) []
      "list of all hosts";

    host-name =
      mkOpt types.str null
      "the name of the device";
  };

  config.assertions = [
    {
      assertion = builtins.elem cfg.host-name cfg.hosts;
      message = "config.modules.nixos.host-name not in config.modules.nixos.hosts";
    }
    {
      assertion = cfg.host-name != null;
      message = "config.modules.nixos.host-name must be set";
    }
  ];
}
