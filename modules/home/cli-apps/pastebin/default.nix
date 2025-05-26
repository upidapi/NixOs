{
  config,
  lib,
  my_lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.cli-apps.pastebin;
in {
  options.modules.home.cli-apps.pastebin = mkEnableOpt "";

  config = mkIf cfg.enable {
    home.packages = [
      (
        pkgs.writeShellScriptBin "pastebin"
        (builtins.readFile ./transfer.sh)
      )
    ];
  };
}
