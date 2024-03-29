{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.core.flakes;
in {
  options.modules.nixos.core.flakes =
    mkEnableOpt "enables nixos flakes";

  config = mkIf cfg.enable {
    # for flakes
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
