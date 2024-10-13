{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.os.services.nginx;
in {
  options.modules.nixos.os.services.nginx = mkEnableOpt "";

  config = mkIf cfg.enable {
    # might remove this
  };
}
