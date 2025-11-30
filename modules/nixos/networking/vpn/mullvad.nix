{
  config,
  lib,
  mlib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt enableAnd;
  cfg = config.modules.nixos.networking.vpn.mullvad;
in {
  options.modules.nixos.networking.vpn.mullvad =
    mkEnableOpt "";


  config = lib.mkMerge [
    (mkIf cfg.enable {
      services.mullvad-vpn = enableAnd {
        package = pkgs.mullvad-vpn;
      };
    })
  ];
}
