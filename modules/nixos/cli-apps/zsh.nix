{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.cli-apps.zsh;
in {
  options.modules.nixos.cli-apps.zsh =
    mkEnableOpt
    "enables the zsh shell";

  config.programs = mkIf cfg.enable {
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting = enable;

      shellAliases = {
        vi = "nvim";
        vim = "nvim";
        c = "clear";
      };
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
