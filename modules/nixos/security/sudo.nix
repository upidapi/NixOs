{
  lib,
  my_lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.security.sudo;
in {
  options.modules.nixos.security.sudo =
    mkEnableOpt "sudo config";

  config = mkIf cfg.enable {
    # disable the initial warning / lecture when using sudo
    security.sudo.extraConfig = ''
      Defaults lecture="never"
    '';
  };
}
