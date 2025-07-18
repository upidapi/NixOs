{
  lib,
  my_lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.security.cfg-perms;
in {
  options.modules.nixos.security.cfg-perms =
    mkEnableOpt "set perms of the repo";

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings = {
      # the name is arbitrary
      "set-cfg-perm" = {
        "${config.modules.nixos.nix.cfg-path}" = {
          Z = {
            user = "root";
            group = "wheel";
            mode = "0664";
          };
        };
      };
    };
  };
}
