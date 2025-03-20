{
  config,
  # osConfig,
  my_lib,
  lib,
  inputs,
  # pkgs,
  self,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.misc.sops;
in {
  # might want to remove/disable the import when
  # this modules is disabled
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  options.modules.home.misc.sops =
    mkEnableOpt "enables sops";

  config = mkIf cfg.enable {
    # home.packages = [
    #   pkgs.sops
    # ];

    /*
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
            + "${osConfig.modules.nixos.meta.host-name}";
        };
      };
    };
    */

    home.file = {
      /*
      "test" = {
        text = "test";
      };
      */

      ".ssh/id_ed25519" = {
        source =
          config.lib.file.mkOutOfStoreSymlink
          "/etc/ssh/users/${config.home.username}_ed25519";
      };
    };

    sops = {
      defaultSopsFile = "${self}/secrets/users/${config.home.username}.yaml";

      age = {
        keyFile = "${config.home.homeDirectory}/.sops-nix-key.txt";

        sshKeyPaths = [
          "/etc/ssh/users/${config.home.username}_ed25519"
        ];

        generateKey = true;
      };

      secrets = {
        # would be placed in ~/test, getting the value from "${defaultSopsFile}/test"
        # "test" = {
        #   path = "test";
        #   mode = "0400";
        # };

        "ai-api-keys/ANTHROPIC_API_KEY" = {
          path = "test";
          mode = "0400";
        };

        # "ai-api-keys/ANTHROPIC_API_KEY" = {
        #   # owner = "root";
        #   # group = "wheel";
        #   mode = "0400";
        # };
        #
        # "ai-api-keys/OPENAI_API_KEY" = {
        #   # owner = "root";
        #   # group = "wheel";
        #   mode = "0400";
        # };
      };
    };
  };
}
