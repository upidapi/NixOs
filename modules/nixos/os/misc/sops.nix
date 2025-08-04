{
  config,
  mlib,
  lib,
  inputs,
  pkgs,
  self,
  ...
}: let
  inherit (mlib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  # inherit (lib.attrsets) genAttrs;
  cfg = config.modules.nixos.os.misc.sops;
  # ssh_path = "/persist/system/etc/ssh";
  ssh_path = "/etc/ssh";
  secrets_path = "${self}/secrets";
in {
  # might want to remove/disable the import when
  # this modules is disabled
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.modules.nixos.os.misc.sops =
    mkEnableOpt "enables sops";

  # we can use "scalpel" to insert keys into arbitrary positions
  # during runtime

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sops
      age
      # sops-to-age
    ];

    sops = let
      hostName = config.modules.nixos.meta.host-name;
      infraFile = "${secrets_path}/infra.yaml";
    in {
      defaultSopsFile = "${secrets_path}/hosts/${hostName}.yaml";

      # NOTE: if you want to generate the age key from host ssh keys:
      # Sops needs access to the keys before the persist dirs are even mounted;
      # so just persisting the keys won't work, we must point at /persist

      age.keyFile = "/persist/sops-nix-key.txt";

      secrets =
        {
          # the attr names equate to the key names for the sops keys

          # admin stuff
          "github-key" = {
            path = "${ssh_path}/github";
            owner = "root";
            group = "wheel";
            mode = "0440";
            sopsFile = infraFile;
          };

          "admin-ssh-key" = {
            path = "${ssh_path}/ssh_admin_ed25519_key";
            owner = "root";
            group = "wheel";
            mode = "0440";
            sopsFile = infraFile;
          };

          # host key
          "hosts/${hostName}" = {
            path = "${ssh_path}/ssh_host_ed25519_key";
            owner = "root";
            group = "wheel";
            mode = "0600";
            sopsFile = infraFile;
          };
        }
        # Placing the keys directly in /home causes home manager to break
        # on reboot. eg. it causes (at least) /home/${user name}/.config
        # to not be generated.
        # Instead we place it here and it will be symlinked to
        # /home/${user name}/.ssh/id_ed25519 by hm later on
        // (
          builtins.listToAttrs (
            builtins.map
            (user-name: {
              name = "ssh-key";
              value = {
                path = "${ssh_path}/users/${user-name}_ed25519";
                owner = user-name;
                mode = "0400";
                sopsFile = "${secrets_path}/users/${user-name}.yaml";
              };
            })
            # when you add new users add them here
            ["upidapi"]
          )
        );
    };
  };
}
