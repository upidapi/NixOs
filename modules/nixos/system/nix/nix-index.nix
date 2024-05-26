{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.system.nix.nix-index;
in {
  options.modules.nixos.system.nix.nix-index =
    mkEnableOpt
    "enables nix-index / nix-locate that can be used to find files in the store";

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.nix-index
    ];
  };
}
