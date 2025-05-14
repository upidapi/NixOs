{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.homelab.authelia;
in {
  options.modules.nixos.homelab.authelia = mkEnableOpt "authelia";

  config =
    mkIf cfg.enable {
    };
}
