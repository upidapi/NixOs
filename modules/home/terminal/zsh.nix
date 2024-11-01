{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable mkBoolOpt;
  inherit (lib) mkIf mkBefore;
  cfg = config.modules.home.terminal.zsh;
in {
  options.modules.home.terminal.zsh =
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
          unpage = "PAGER=cat";
          nix-unfree = "NIXPKGS_ALLOW_UNFREE=1";
          ds = "dev-shell";
          dsu = "env NIXPKGS_ALLOW_UNFREE=1 dev-shell";

          e = "$EDITOR";
          c = "clear";
          # l = "ls -lah";
          l = "eza -lah";
          # persistent env su
          pesu = "sudo --preserve-env su --preserve-environment";
          # pull file from the store into tha same place but editable
          /*
          cdmk = ''_cdmk() {mkdir -p "$1"; cd "$1"}; _cdmk'';

          unstore =
            ''_unstore() {''
            + ''[ -L "$1" ] && cp --remove-destination "$(readlink "$1")" "$1";''
            + ''chown $(whoami) "$1"; chmod +w "$1"''
            + ''}; _unstore'';
          */

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
