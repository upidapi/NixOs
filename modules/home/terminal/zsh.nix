{
  config,
  mlib,
  lib,
  pkgs,
  ...
}: let
  inherit (mlib) mkEnableOpt enable;
  inherit (lib) mkIf mkBefore;
  cfg = config.modules.home.terminal.zsh;
in {
  options.modules.home.terminal.zsh =
    mkEnableOpt "enables the zsh shell";
  config = mkIf cfg.enable {
    programs = {
      zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion = enable;
        syntaxHighlighting = enable;

        inherit (config.modules.home.terminal) shellAliases;

        dotDir = ".zsh";
        history = {
          size = 10000;
          path = "$HOME/.zsh/history";
        };

        initContent = mkBefore ''
          set -o vi

          # Improved vim bindings.
          source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

          cdmk() {
            mkdir -p "$1"; cd "$1"
          }

          # Takes a symlink to the store and unlinks it so that the
          # file (or dir) it pointed to is placed there insted
          unstore() {
            [ -L "$1" ] &&
            cp --remove-destination "$(readlink "$1")" "$1";

            chown $(whoami) "$1"; chmod +w "$1"
          }
        '';
      };
    };
  };
}
