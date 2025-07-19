{
  my_lib,
  lib,
  config,
  self,
  ...
}: let
  inherit (my_lib.opt) mkOpt;
  inherit (lib) types;
  cfg = config.modules.nixos.nix;
in {
  imports = [
    ./gc.nix
    ./flakes.nix
    ./cachix.nix
    ./misc.nix
  ];

  # used by other modules
  options.modules.nixos.nix = {
    cfg-path =
      mkOpt types.str null
      "that absolute path of the nixos config";
  };

  config = {
    environment.sessionVariables = {
      NIXOS_CONFIG_PATH = cfg.cfg-path;
    };

    nix.extraOptions = ''
      !include ${config.sops.templates."nix-extra-config".path}
    '';
    # nix.checkConfig = false;
    sops.templates."nix-extra-config" = {
      content = ''
        access-tokens = github.com=${config.sops.placeholder."github-nix-token"}
      '';
      mode = "0444";
    };
    sops.secrets."github-nix-token" = {
      sopsFile = "${self}/secrets/shared.yaml";
      restartUnits = ["nix-daemon.service"];
    };
  };
}
