{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.terminal.direnv;
in {
  options.modules.home.terminal.direnv =
    mkEnableOpt
    "Whether or not to add direnv, it automatically sets the env when cding";

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # auto enter sec dev shell when going into the sec folder
    # home.file."persist/prog/sec/.envrc".text = ''
    #   export NIXPKGS_ALLOW_UNFREE=1
    #
    #   # avoid recursive calls in fhs env
    #   if [ -z "$IN_NIX_SHELL" ]; then
    #       use flake $NIXOS_CONFIG_PATH#sec --builders "" --impure
    #   fi
    # '';
  };
}
