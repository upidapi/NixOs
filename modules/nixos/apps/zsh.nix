{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.apps.zsh;
in {
  options.modules.nixos.apps.zsh = mkEnableOpt "enables the zsh shell";

  config.programs = mkIf cfg.enable {
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      syntaxHighlighting = enable;
    };

    starship = {
      enable = true;
      settings = {
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[✗](bold red) ";
          vicmd_symbol = "[](bold blue) ";
        };
      };
    };
  };
}
