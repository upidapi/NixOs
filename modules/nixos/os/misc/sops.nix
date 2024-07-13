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
  inherit (lib.attrsets) genAttrs;
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

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sops
      age
      # sops-to-age
    ];

    sops = {
      defaultSopsFile = "${secrets_path}/infra.yaml";
      # age.keyFile = "/home/user/.config/sops/age/keys.txt";

      # move this?
      age = {
        keyFile = "/persist/sops-nix-key.txt";

        # TODO: figure out how to establish install / continued trust
        #  maybe https://github.com/librephoenix/nixos-config could help
        sshKeyPaths = [
          "${ssh_path}/ssh_admin_ed25519_key"
          "${ssh_path}/ssh_host_ed25519_key"
        ];
      };

      secrets =
        {
          # the attr names equate to the key names for the sops keys

          # admin stuff
          "github-key" = {
            path = "${ssh_path}/github";
            owner = "root";
            group = "wheel";
            mode = "0440";
          };

          "admin-ssh-key" = {
            path = "${ssh_path}/ssh_admin_ed25519_key";
            owner = "root";
            group = "wheel";
            mode = "0440";
          };

          # host key
          "hosts/${config.modules.nixos.meta.host-name}" = {
            path = "${ssh_path}/ssh_host_ed25519_key";
            owner = "root";
            group = "wheel";
            mode = "0440";
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
