{
  lib,
  my_lib,
  config,
  ...
}: let
  inherit (lib) types;
  inherit (my_lib.opt) mkOpt;
  cfg = config.modules.nixos.meta;
in {
  options.modules.nixos.meta = {
    hosts =
      mkOpt (types.listOf types.str) []
      "list of all hosts";
    
    # prob unecicary since we can just use keys.machines
    host-name =
      mkOpt types.str null
      "the name of the device";
  };

  config.assertions = [
    {
      assertion = builtins.elem cfg.host-name cfg.hosts;
      message = "config.modules.nixos.meta.host-name not in config.modules.nixos.meta.hosts";
    }
    {
      assertion = cfg.host-name != null;
      message = "config.modules.nixos.meta.host-name must be set";
    }
  ];
}
