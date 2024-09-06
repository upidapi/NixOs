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
    };
  };
}
