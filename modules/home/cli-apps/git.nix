{
  osConfig,
  config,
  lib,
  const,
  mlib,
  pkgs,
  ...
}: let
  inherit (const) keys;
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt enable;
  cfg = config.modules.home.cli-apps.git;
  pubKey = keys.users."${config.home.username}";
in {
  options.modules.home.cli-apps.git =
    mkEnableOpt "Whether or not to add git";

  config = mkIf cfg.enable {
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
    };

    programs.git = {
      enable = true;

      settings = {
        alias = {
          # add all git aliases here
          a = "add";
          aa = "add --all";

          d = "diff";

          pl = "pull";
          pu = "push";

          s = "status";

          c = "commit";
          cm = "commit -m";
          ca = "commit --amend";

          C = "clone";

          rb = "rebase";
          rba = "rebase --abort";
          rbc = "rebase --continue";
          rbi = "rebase --interactive";

          r = "restore";
          rs = "restore --staged";

          tree = "log --graph --oneline --decorate --all";
        };

        user.name = "upidapi";
        user.email = "videw@icloud.com";

        delta = {
          enable = true;
          options = {
            navigate = true;
            dark = true;
            line-numbers = true;
          };
        };

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
          "${osConfig.modules.nixos.misc.nix.cfg-path}"
          "${osConfig.modules.nixos.misc.nix.cfg-path}/.git"
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
        # key = pubKey; #  use the defaultKeyCommand instead
        signByDefault = true;
        key = null; # you have to set this :)
      };

      ignores = [
      ];

      attributes = [
        # Source files
        "*.c     text eol=lf diff=cpp"
        "*.cc    text eol=lf diff=cpp"
        "*.cxx   text eol=lf diff=cpp"
        "*.cpp   text eol=lf diff=cpp"
        "*.cpi   text eol=lf diff=cpp"
        "*.c++   text eol=lf diff=cpp"
        "*.hpp   text eol=lf diff=cpp"
        "*.h     text eol=lf diff=cpp"
        "*.h++   text eol=lf diff=cpp"
        "*.hh    text eol=lf diff=cpp"

        ".py  text eol=lf diff=python"
        ".py3 text eol=lf diff=python"

        "*.lua text eol=lf"

        "*.html text  eol=lf diff=html"
        "*.css  text  eol=lf diff=css"

        # Archives
        "*.7z   binary"
        "*.gz   binary"
        "*.tar  binary"
        "*.tgz  binary"
        "*.zip  binary"

        # Scripts
        "*.bash text eol=lf"
        "*.fish text eol=lf"
        "*.sh   text eol=lf"
        "*.zsh  text eol=lf"
        "*.nu   text eol=lf"

        # Executables
        "*.o    binary"
        "*.out  binary"

        # Normal text files
        "*.txt  text eol=lf"
        "*.csv  text eol=lf"
        "*.norg text eol=lf"
        "*.md   text eol=lf diff=markdown"
        "*.tex  text diff=tex"
      ];
    };
  };
}
