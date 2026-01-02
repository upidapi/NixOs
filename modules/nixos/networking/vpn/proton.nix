{
  config,
  lib,
  mlib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.networking.vpn.proton;
in {
  options.modules.nixos.networking.vpn.proton = mkEnableOpt "";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      protonvpn-gui

      proton-vpn-cli
    ];
  };
}
