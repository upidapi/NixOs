{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable mkBoolOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.cli-apps.zsh;
in {
  options.modules.home.cli-apps.zsh =
    mkEnableOpt
    "enables the zsh shell"
    // {
      set-shell = mkBoolOpt false "sets the users shell to zsh";
    };

  config.programs = mkIf cfg.enable {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion = enable;
      syntaxHighlighting = enable;

      shellAliases = {
        # s = "doas -s";
        # sudo = "doas -s";
        e = "$EDITOR";
        c = "clear";
      };

      history.size = 10000;
      history.path = "${config.home.homeDirectory}/.zsh/history";
    };

    starship = {
      enable = true;
      settings = {
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red) ";
          # vicmd_symbol = "[](bold blue) ";
        };
      };
    };
  };
}