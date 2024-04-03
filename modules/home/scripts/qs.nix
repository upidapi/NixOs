{
  config,
  osConfig,
  lib,
  pkgs,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.scripts.qs;
in {
  options.modules.home.scripts.qs =
    mkEnableOpt
    "Whether or not to add the qs command";

  # qs i.e quick switch
  # just a shorthand for regen-nixos
  config = mkIf cfg.enable {
    modules.home.scripts.regen-nixos.enable = true;
    home.packages = [
      (pkgs.writeShellScriptBin "qs" ''
        # we shuld try to store the current profile
        # and use that as a default
        if [[ $# -eq 0 ]];
          then profile="default";
          else profile="$1";
        fi

        regen-nixos "$profile" "--no-commit"
      '')
    ];
  };
}
