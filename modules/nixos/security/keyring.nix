{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.security.keyring;
in {
  options.modules.nixos.security.keyring = mkEnableOpt "";

  # doesnt work
  config = mkIf cfg.enable {
    # FROM: https://wiki.nixos.org/wiki/Secret_Service
    services.gnome.gnome-keyring.enable = true;
  };
}
