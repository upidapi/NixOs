{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf mkOption;
  inherit (lib.types) attrsOf str package;
  cfg = config.modules.home.terminal;
in {
  options.modules.home.terminal =
    (mkEnableOpt "enables the zsh shell")
    // {
      shellAliases = mkOption {
        type = attrsOf str;
        default = {};
        description = "a set of all shell aliases";
      };

      defaultShell = mkOption {
        type = package;
      };
    };

  imports = [
    ./nushell
    ./direnv.nix
    ./starship.nix
    ./tmux.nix
    ./zsh.nix
  ];

  config = mkIf cfg.enable {
    xdg.configFile."shell".source = lib.getExe cfg.defaultShell;

    # xdg.configFile."shell" = {
    #   executable = true;
    #   text = ''
    #     #!/bin/sh
    #     exec ${cfg.defaultShell}/bin/zsh "$@"
    #   '';
    # };

    modules.home.terminal.shellAliases = {
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
  };
}
