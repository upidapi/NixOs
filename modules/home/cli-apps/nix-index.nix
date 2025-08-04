{
  config,
  lib,
  mlib,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.cli-apps.nix-index;
in {
  options.modules.home.cli-apps.nix-index =
    mkEnableOpt "enables nix-index / nix-locate that can be used to find files in the store";

  imports = [inputs.nix-index-db.homeModules.nix-index];

  config = mkIf cfg.enable {
    programs = {
      nix-index = {
        enable = true;
        symlinkToCacheHome = true;
      };

      nix-index-database.comma.enable = true;
    };
  };
}
