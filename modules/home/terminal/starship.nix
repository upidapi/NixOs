{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.terminal.starship;
in {
  options.modules.home.terminal.starship =
    mkEnableOpt "enable starship, a fancy promt";

  config = mkIf cfg.enable {
    # might not what to hardcode this
    programs.starship = {
      enable = true;
      settings = {
        # format = "\${custom.simple_nix_shell}$directory$character";
        format = builtins.concatStringsSep "" [
          "\${custom.shell_lvl}"
          "$username"
          "\${custom.spacing}"
          "$hostname"
          "$nix_shell"
          "$directory"
          "$character"
        ];
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

        # there is (afaik) no way to determine if we're in a "nix shell"
        # https://github.com/NixOS/nix/issues/6677
        nix_shell = {
          impure_msg = "[❄️](bold red)";
          pure_msg = "[❄️](bold green)";
          unknown_msg = "[❄️](bold yellow)";
          format = "[\\[$state $name\\]](bold blue) ";
        };

        username = {
          style_user = "bold green";
          format = "[$user]($style)";
        };

        # ssh
        hostname = {
          ssh_only = true;
          format = "@[$hostname]($style) ";
          trim_at = ".";
        };

        # the output is trimmed so we have to do this shit instead
        custom.spacing = {
          when = ''
            if [[ -z "$SSH_CONNECTION" ]]; then
              if [[ "$(whoami)" == "root" ]]; then
                exit 0
              fi
            fi
            exit 1
          '';
          format = " ";
        };

        custom.shell_lvl = {
          when = ''if [[ "$SHLVL" == 2 ]]; then exit 1; fi'';
          command = ''(( res = "$SHLVL" - 1 )); echo "$res"'';
          format = "$output ";
        };

        # format = "\${custom.username}\${custom.userroot}$hostname$nix_shell$directory$character";
        /*
        custom.username = {
          when = true;
          command = ''
            username="$(whoami)"
            if [[ -z "{SSH_CONNECTION}" ]]; then
              if [[ "$username" != "root" ]]; then
                echo "$username"
              fi
            fi
          '';
          format = "[$output](bold dimmed green)";
        };
        custom.userroot = {
          when = true;
          command = ''
            username="$(whoami)"
            if [[ "$username" == "root" ]]; then
              if [[ -z "{SSH_CONNECTION}" ]]; then
                echo "root"
              else;
                echo "root "
              fi
            fi
          '';
          format = "[$output](bold red)";
        };
        */

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
}
