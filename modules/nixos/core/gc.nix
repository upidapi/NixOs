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
    mkEnableOpt "enables nixos flakes";

  config = mkIf cfg.enable {
     nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };
}
