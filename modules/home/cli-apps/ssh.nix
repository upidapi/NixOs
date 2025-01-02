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
      # TODO: check if ssh-agent is running before calling ssh-add
      #  ps -e | grep ssh-agent

      # >>> ps | grep ssh-agent
      # 329 │ 3524 │ 3342 │ ssh-agent                                 │ Sleeping │  0.00 │    6.6 MiB │  10.3 MiB

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
