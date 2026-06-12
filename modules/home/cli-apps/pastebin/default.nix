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
      (pkgs.writers.writePython3Bin "pastebin" {
        libraries = [
          pkgs.python3Packages.requests
        ];

        # Optional: Disables the default flake8 linter check during build time.
        # This prevents style or formatting errors from failing your build.
        doCheck = false;
      } (builtins.readFile ./pastebin.py))
    ];
  };
}
