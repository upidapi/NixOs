{
  config,
  lib,
  my_lib,
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
      clock24 = true;
      keyMode = "vi";
      escapeTime = 0;
      # mouse = true;

      # sets TERM var to advertise capabilitys
      terminal = "tmux-256color";

      extraConfig = ''
        set -g @dracula-show-battery false
        set -g @dracula-show-network false
        set -g @dracula-show-weather false
      '';
    };

    # EXP: tmux-pain-control (better binds)
  };
}
