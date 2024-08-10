{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt enable;
  cfg = config.modules.home.cli-apps.ssh;
in {
  options.modules.home.cli-apps.ssh = mkEnableOpt "enables ssh stuff";
  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      # addKeysToAgent = "5m" ?
      # startAgent = true;
      # agentTimeout = "1m";
      # extraConfig = ''
      #   AddKeysToAgent yes
      # '';
    };
    services.ssh-agent = enable;
  };
}
