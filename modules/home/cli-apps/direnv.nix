{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.cli-apps.direnv;
in {
  options.modules.home.cli-apps.direnv =
    mkEnableOpt
    "Whether or not to add direnv, it automatically sets the env when cding";

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # auto enter sec dev shell when going into the sec folder
    home.file."persist/prog/sec/.direnv".text = "use flake \"$NIXOS_CONFIG_PATH\"#sec";
  };
}
