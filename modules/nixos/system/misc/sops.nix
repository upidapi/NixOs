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
      defaultSopsFile = "${self}/secrets/infra.yaml";
      # age.keyFile = "/home/user/.config/sops/age/keys.txt";

      # move this?
      age.keyFile = "/persist/sops-nix-key.txt";

      # FIXME: dont just give the secrets to "upidapi"
      #  give the github key to the admin / infra access
      #  and the .ssh key should probably be user not host specific

      secrets = {
        /*
        "sops-age-key" = {
          path = "/home/upidapi/.config/sops/age/keys.txt";
          owner = "upidapi";
          mode = "0400";
        };

        # this causes (at least) /home/upidapi/.config to not be generated

        # the key names equate to the key names for the sops keys
        "github-key" = {
          path = "/home/upidapi/.ssh/github";
          owner = "upidapi";
          mode = "0400";
        };
        */
        "hosts/upidapi-nix-pc" = {
          path = "/home/upidapi/.ssh/id_ed25519";
          owner = "upidapi";
          mode = "0400";
          # "${self}/secrets/infra/hosts/"
          # + "${config.modules.nixos.host-name}";
          # format = "binary";
        };
      };
    };
  };
}
