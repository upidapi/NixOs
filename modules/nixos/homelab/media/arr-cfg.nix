{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.homelab.media.arr-cfg;

  buildarr_cfg = {};
in {
  options.modules.nixos.homelab.media.arr-cfg = mkEnableOpt "";

  config = mkIf cfg.enable {
    
  };
}
