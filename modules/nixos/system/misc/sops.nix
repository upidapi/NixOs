{
  config,
  my_lib,
  lib,
  inputs,
  pkgs,
  self,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.system.misc.sops;

  # FIXME: only add the
  ssh-cfg-path = "${config.home.homeDirectory}/.ssh";
in {
  # NOTE: not used

  # might want to remove/disable the import when
  # this modules is disabled
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.modules.nixos.system.misc.sops =
    mkEnableOpt "enables sops";

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.sops
    ];

    sops = {
      defaultSopsFile = "${self}/secrets/secrets.yaml";
      # age.keyFile = "/home/user/.config/sops/age/keys.txt";
      age.keyFile = "/persist/sops-nix-key.txt";

      secrets = {
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
            + "${config.modules.nixos.host-name}";
          format = "binary";
        };
      };
    };
  };
}
