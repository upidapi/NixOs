{
  config,
  mlib,
  lib,
  pkgs,
  ...
}: let
  inherit (mlib.opt) mkEnableOpt mkOpt;
  inherit (lib) mkIf types;
  cfg = config.modules.nixos.nix.flakes;
in {
  options.modules.nixos.nix.flakes =
    mkEnableOpt "enables nixos flakes"
    // {
      profile =
        mkOpt types.str null
        "the key name of the flake profile";
    };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.git # for fetching flakes from git repos
    ];

    # for flakes
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
