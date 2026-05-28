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
  cfg = config.modules.nixos.homelab.media.meilisearch;
in {
  options.modules.nixos.homelab.media.meilisearch = mkEnableOpt "";

  config = mkIf cfg.enable {
    services.meilisearch = {
      enable = true;
      listenPort = ports.meilisearch;
    };
  };
}
