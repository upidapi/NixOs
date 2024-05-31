{
  config,
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
  # https://github.com/NixOS/nixpkgs/blob/4a9b788bf5d4bb1016770b7639411aafbcb7991c/pkgs/development/interpreters/python/python-packages-base.nix#L45
  config = mkIf cfg.enable {
    home.packages = [
      (
        /*
        pkgs.writers.writePython3Bin
        "qs"
        {
          # TODO: disable E203 globally since it conflicts with ruff
          flakeIgnore = ["W291" "W293" "E501" "E303" "W503" "E203"];
        }
        (builtins.readFile ./main.py)
        */
        pkgs.python3.pkgs.buildPythonApplication {
          pname = "qs";
          version = "1.0";
          pyproject = true;
          src = ./.;
          nativeBuildInputs = [pkgs.python3.pkgs.setuptools];
          # propagatedBuildInputs = [python3.pkg.requests];
          # pythonImportsCheck = ["src"];
        }
      )
    ];
  };
}
