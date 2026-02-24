{
  config,
  lib,
  mlib,
  const,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  inherit (const) ports;
  cfg = config.modules.nixos.homelab.media.autobrr;
in {
  options.modules.nixos.homelab.media.autobrr = mkEnableOpt "";

  imports = [./base.nix];

  config = mkIf cfg.enable {
    # autobrr.serviceConfig = {
    #   DynamicUser = false;
    #   User = "autobrr";
    #   Group = "media";
    # };

    # https://autobrr.com/configuration/indexers
    # https://github.com/autobrr/autobrr/issues/2144
    #  torrentLeach torrents often mislabeled as freeleech
    #  use a filter for >12GB or is boxset
    services.autobrr = {
      # maybe use this instead
      # https://github.com/rasmus-kirk/nixarr/blob/204da9209ad4e921c3562a6bca5ac8ad5b6ed9bc/nixarr/autobrr/default.nix
      enable = true;

      user = "autobrr";
      # group = "media";

      # secretFile = config.sops.secrets."autobrr/session-secret".path;
      settings = {
        host = "127.0.0.1";
        port = ports.autobrr;

        checkForUpdates = true;
        logLevel = "DEBUG";
      };

      # declarrCfg = {
      # };
    };
  };
}
