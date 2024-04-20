{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.home.cli-apps.zsh;
in {
  options.modules.home.cli-apps.zsh =
    mkEnableOpt
    "enables the zsh shell";

  config.programs = mkIf cfg.enable {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion = enable;
      syntaxHighlighting = enable;

      shellAliases = {
        e = "$EDITOR";
        vi = "nvim";
        vim = "nvim";
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
