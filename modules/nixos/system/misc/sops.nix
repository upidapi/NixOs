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
        "github-key" = {
          path = "/home/upidapi/.ssh/github";
          mode = "0400";
          sopsFile = "${self}/secrets/infra.yaml";
        };

        "hosts/upidapi-nix-pc" = {
          path = "/home/upidapi/.ssh/id_ed25519";
          mode = "0400";
          sopsFile = "${self}/secrets/infra.yaml";
          # "${self}/secrets/infra/hosts/"
          # + "${config.modules.nixos.host-name}";
          # format = "binary";
        };
      };
    };
  };
}
