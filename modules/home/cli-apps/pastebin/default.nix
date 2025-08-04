{
  config,
  lib,
  mlib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit
    (mlib)
    mkEnableOpt
    ;
  cfg = config.modules.home.cli-apps.pastebin;
in {
  options.modules.home.cli-apps.pastebin = mkEnableOpt "";

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "pastebin";

        runtimeInputs = [
          pkgs.zip
        ];

        text = builtins.readFile ./transfer.sh;
      })
    ];
  };
}
