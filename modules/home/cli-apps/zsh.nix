{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable mkBoolOpt;
  inherit (lib) mkIf mkBefore;
  cfg = config.modules.home.cli-apps.zsh;
in {
  options.modules.home.cli-apps.zsh =
    mkEnableOpt
    "enables the zsh shell"
    // {
      set-shell = mkBoolOpt false "sets the users shell to zsh";
    };

  config = mkIf cfg.enable {
    # xdg.configFile."shell".source = mkIf cfg.set-shell (lib.getExe pkgs.zsh);
    xdg.configFile."shell" = {
      executable = true;
      text = ''
        #!/bin/sh
        exec ${pkgs.zsh}/bin/zsh "$@"
      '';
    };

    programs = {
      zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion = enable;
        syntaxHighlighting = enable;

        shellAliases = {
          # s = "doas -s";
          # sudo = "doas -s";
          unpage = "env PAGER=cat";
          ds = "dev-shell";
          e = "$EDITOR";
          c = "clear";
          # l = "ls -lah";
          l = "eza -lah";
          # persistent env su
          pesu = "sudo --preserve-env su --preserve-environment";
          # pull file from the store into tha same place but editable
          unstore =
            ''unlink() {''
            + ''[ -L "$1" ] && cp --remove-destination "$(readlink "$1")" "$1";''
            + ''chown $(whoami) "$1"; chmod +w "$1"''
            + ''}; unlink'';
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          "....." = "cd ../../../..";
        };

        dotDir = ".zsh";
        history = {
          size = 10000;
          path = "$HOME/.zsh/history";
        };

        initExtra = mkBefore ''
          set -o vi

          # Improved vim bindings.
          source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
        '';
      };

      starship = {
        enable = true;
        settings = {
          # format = "\${custom.simple_nix_shell}$directory$character";
          format = "$nix_shell$directory$character";
          add_newline = true;

          directory = {
            truncate_to_repo = false;
            read_only = "";
            truncation_symbol = ".../";
          };

          # right_format = "$all";
          character = {
            success_symbol = "[➜](bold green)";
            error_symbol = "[➜](bold red)";
            # vicmd_symbol = "[](bold blue) ";
          };

          nix_shell = {
            impure_msg = "[❄️](bold red)";
            pure_msg = "[❄️](bold green)";
            unknown_msg = "[❄️](bold yellow)";
            format = "[\\[$state $name\\]](bold blue) ";
          };

          /*
          custom.simple_nix_shell = {
            command = ''
              if [[ "$IN_NIX_SHELL" == "impure" ]]; then
                pure_icon="-";

              elif [[ "$IN_NIX_SHELL" == "pure" ]]; then
                pure_icon="+";

              elif [[ "$IN_NIX_SHELL" == "unknown" ]]; then
                pure_icon="o";

              else;
                echo "wut"
              fi

              echo "$pure_icon $name"
            '';
            when = "if [[ $name == '' ]]; then exit 1; fi";
            format = "[\\[❄️ $output\\]](bright-cyan) ";
          };
          */
        };
      };
    };
  };
}
