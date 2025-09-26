{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt enable;
  cfg = config.modules.home.cli-apps.ssh;
in {
  options.modules.home.cli-apps.ssh = mkEnableOpt "enables ssh stuff";
  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*".addKeysToAgent = "5m";
      # startAgent = true;
      # agentTimeout = "1m";
      # extraConfig = ''
      #   AddKeysToAgent yes
      # '';
    };
    services.ssh-agent = enable;
  };
}
