{
  config,
  osConfig,
  my_lib,
  lib,
  inputs,
  pkgs,
  self,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.misc.sops;
  ssh-cfg-path = "${config.home.homeDirectory}/.ssh";
in {
  # might want to remove/disable the import when
  # this modules is disabled
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  options.modules.home.misc.sops =
    mkEnableOpt "enables sops";

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.sops
    ];

    sops = {
      defaultSopsFile = "${self}/secrets/secrets.yaml";
      # age.keyFile = "/home/user/.config/sops/age/keys.txt";
      age.keyFile = "/persist/sops-nix-key.txt";

      secrets = {
        # FIXME: terrible security etc, this way all profiles get the
        #  ssh private key (for the host) / github key

        github = {
          path = "${ssh-cfg-path}/github";
          mode = "0400";
          sopsFile = "${self}/secrets/ssh-keys/github";
          format = "binary";
        };

        upidapi-nix-pc = {
          path = "${ssh-cfg-path}/id_ed25519";
          mode = "0400";
          sopsFile =
            "${self}/secrets/ssh-keys/hosts/"
            + "${osConfig.modules.nixos.host-name}";
          format = "binary";
        };
      };
    };
  };
}
