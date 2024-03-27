{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt mkOpt;
  inherit (lib) mkIf types;
  cfg = config.modules.nixos.core;
in {
  options.modules.nixos.core =
    mkEnableOpt "enables some basic nixos stuff" // {
    nixos-cfg-path = mkOpt types.str null 
      "that absolute path of the nixos config";
  };

  config = mkIf cfg.enable {
    nixos-cfg-path = cfg.nixos-cfg-path;

    # for flakes
    nix.settings.experimental-features = ["nix-command" "flakes"];

    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };
}
