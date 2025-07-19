{
  lib,
  my_lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt disable;
  cfg = config.modules.nixos.security.sudo-rs;
in {
  options.modules.nixos.security.sudo-rs =
    mkEnableOpt "replaces sudo with sudo-rs";

  config = mkIf cfg.enable {
    # doas
    # for backward compat
    # environment.shellAliases = {sudo = "sudo-rs";};
    security = {
      sudo = disable;
      sudo-rs = {
        enable = true;
        /*
           extraRules = [
          {
            groups = ["wheel"];
            keepEnv = true;
          }
        ];
        */
      };
    };
  };
}
