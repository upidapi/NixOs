{
  osConfig,
  config,
  lib,
  keys,
  my_lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt enable;
  cfg = config.modules.home.cli-apps.git;
  pubKey = keys.users."${config.home.username}";
in {
  options.modules.home.cli-apps.git =
    mkEnableOpt "Whether or not to add git";

  # TODO: go from SSH to GPG keys?
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;

      aliases = {
        # add all git aliases here
      };

      delta = {
        enable = true;
        options = {
          navigate = true;
          dark = true;
          line-numbers = true;
        };
      };

      extraConfig = {
        core = {
          editor = "nvim";
          eol = "lf";
          whitespace = "space-before-tab,trailing-space";
        };

        url = {
          "git@github.com".insteadOf = [
            "gh"
            "github"
          ];

          # always use ssh
          # NOTE: might cause problems
          "ssh://git@github.com/".insteadOf = "https://github.com/";
        };

        pull.rebase = true;

        init = {
          defaultBranch = "main";
        };

        safe.directory = [
          # this is here coz /persist/nixos/ isn't owned by us
          # and that makes git angry
          "${osConfig.modules.nixos.nix.cfg-path}"
          "${osConfig.modules.nixos.nix.cfg-path}/.git"
        ];

        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
        fetch.prune = true;
        apply.whitespace = "fix";
        gpg = {
          # REF: https://github.com/Gerg-L/nixos/blob/df472878dba578823a2fe92a44ba9eacd88d93d0/nixosConfigurations/gerg-desktop/git.nix#L20
          format = "ssh";
          ssh.defaultKeyCommand = let
            script = pkgs.writeShellScript "git_key" ''
              if ssh-add -L | grep -vq '${pubKey}'; then
                ssh-add -t 5m ~/.ssh/id_ed25519
              fi
              echo 'key::${pubKey}'
            '';
          in "${script}";
        };
      };

      lfs = enable;

      signing = {
        # NOTE: dont forget to add it to github :)
        key = pubKey;
        signByDefault = true;
      };

      ignores = [
      ];

      attributes = [
      ];

      userName = "upidapi";
      userEmail = "videw@icloud.com";
    };
  };
}
