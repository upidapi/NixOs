{
  config,
  lib,
  my_lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.terminal.tmux;
in {
  options.modules.home.terminal.tmux =
    mkEnableOpt "Whether or not to add tmux";

  config = mkIf cfg.enable {
    # might not what to hardcode this
    programs.tmux = {
      enable = true;

      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        tokyo-night-tmux
      ];

      extraConfig = builtins.readFile ./tmux.conf;
    };
  };
}
