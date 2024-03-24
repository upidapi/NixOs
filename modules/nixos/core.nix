{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.core;
in {
  options.modules.nixos.core =
    mkEnableOpt "enables some basic nixos stuff";

  config = mkIf cfg.enable {
    # for flakes
    nix.settings.experimental-features = ["nix-command" "flakes"];

    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };
}
