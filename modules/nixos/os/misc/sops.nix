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
  cfg = config.modules.nixos.os.misc.sops;
  # ssh_path = "/persist/system/etc/ssh";
  ssh_path = "/etc/ssh";
in {
  # might want to remove/disable the import when
  # this modules is disabled
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.modules.nixos.os.misc.sops =
    mkEnableOpt "enables sops";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sops
      age
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
        */

        # This causes (at least) /home/upidapi/.config to not be generated.
        # Placing the keys directly in /home causes home manager to break
        # on reboot.

        # the key names equate to the key names for the sops keys
        "github-key" = {
          path = "${ssh_path}/github";
          owner = "upidapi";
          mode = "0400";
        };
        "hosts/upidapi-nix-pc" = {
          path = "${ssh_path}/users/upidapi_ed25519";
          owner = "upidapi";
          mode = "0400";
          # "${self}/secrets/infra/hosts/"
          # + "${config.modules.nixos.meta.host-name}";
          # format = "binary";
        };
      };
    };
  };
}
