{
  osConfig,
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.cli-apps.git;
in {
  options.modules.home.cli-apps.git =
    mkEnableOpt "Whether or not to add git";

  config = mkIf cfg.enable {
    # might not what to hardcode this
    programs.git = {
      enable = true;
      userName = "upidapi";
      userEmail = "videw@icloud.com";
      extraConfig = {
        init.defaultBranch = "main";
        safe.directory = [
          "${osConfig.modules.nixos.system.nix.cfg-path}"
          "${osConfig.modules.nixos.system.nix.cfg-path}/.git"
        ];
        pull.rebase = "false";
      };
    };
  };
}
