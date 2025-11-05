{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.games.roblox;
in {
  options.modules.home.games.roblox = mkEnableOpt "";

  # need to use
  # flatpak run org.vinegarhq.Sober
  config = mkIf cfg.enable {
    services.flatpak.packages = [
      "flathub:app/org.vinegarhq.Sober//stable"
    ];
  };
}
