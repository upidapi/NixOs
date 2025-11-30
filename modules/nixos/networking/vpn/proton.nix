{
  config,
  lib,
  mlib,
  pkgs,
  self',
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

      # TODO: use the package in nixpkgs once it lands there
      self'.packages.proton-vpn-cli
    ];
  };
}
