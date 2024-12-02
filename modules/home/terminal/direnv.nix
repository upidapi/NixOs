{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.terminal.direnv;
in {
  options.modules.home.terminal.direnv =
    mkEnableOpt
    "Whether or not to add direnv, it automatically sets the env when cding";

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # auto enter sec dev shell when going into the sec folder
    home.file."persist/prog/sec/.envrc".text = ''
      export NIXPKGS_ALLOW_UNFREE=1

      # avoid recursive calls in fhs env
      if [ -z "$IN_NIX_SHELL" ]; then
          use flake $NIXOS_CONFIG_PATH#sec --builders "" --impure
      fi
    '';
  };
}
# export NIXPKGS_ALLOW_UNFREE=1
#
# cwd=$PWD
#
# file_name=~/test3.txt
#
# echo "" >> "$file_name"
# echo "" >> "$file_name"
# echo "$(date)" >> "$file_name"
# echo "pwd: $PWD" >> "$file_name"
#
# # avoid recursive calls in fhs env
# if [ -z "$IN_NIX_SHELL" ]; then
#     echo "$(date)" >> "$file_name"
#     echo "pwd 2: $PWD" >> "$file_name"
#     use flake $NIXOS_CONFIG_PATH#sec --builders "" --impure
#
#     echo "$(date)" >> "$file_name"
#     echo "pwd 3: $PWD" >> "$file_name"
# fi

