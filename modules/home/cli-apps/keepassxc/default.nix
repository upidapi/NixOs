{
  osConfig,
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.cli-apps.keepassxc;
in {
  imports = [
    ./base.nix
  ];

  options.modules.home.cli-apps.keepassxc =
    mkEnableOpt "Whether or not to add keepassxc";

  config = mkIf cfg.enable {
    programs.keepassxc = {
      enable = true;
      browserIntegration.firefox = true;

      settings = {
        General = {
          ConfigVersion = 2;
          UseAtomicSaves = true;
        };
        Browser = {
          Enabled = true;
          SearchInAllDatabases = true;
        };
        FdoSecrets = {
          Enabled = true;
        };
        GUI = {
          ApplicationTheme = "dark";
          ColorPasswords = true;
          # MinimizeOnClose = true;
          # MinimizeOnStartup = true;
          # MinimizeToTray = true;
          MonospaceNotes = true;
          # ShowTrayIcon = true;
          # TrayIconAppearance = "monochrome-light";
        };
        PasswordGenerator = {
          AdditionalChars = "";
          ExcludedChars = "";
          Length = 64;
        };
        Security = {
          # times are in seconds
          ClearClipboardTimeout = 30;
          EnableCopyOnDoubleClick = true;
          IconDownloadFallback = true;
          LockDatabaseIdle = true;
          LockDatabaseIdleSeconds = 10 * 60;
        };
      };
    };
  };
}
