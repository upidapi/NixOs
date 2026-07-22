{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.terminal.nix-your-shell;
in {
  options.modules.home.terminal.nix-your-shell = mkEnableOpt "";

  config = mkIf cfg.enable {
    programs.nix-your-shell = {
      enable = true;

      # Optional: Enable for selected shells. Default: `home.shell.enable<Shell>Integration`.
      # enableFishIntegration = true;
      # enableNushellIntegration = true;
      # enableZshIntegration = true;

      # Optional: Whether to pipe the build output through nix-output-monitor. Default: false.
      # nix-output-monitor.enable = true;
    };
  };
}
