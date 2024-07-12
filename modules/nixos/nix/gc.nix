{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.nix.gc;
in {
  options.modules.nixos.nix.gc =
    mkEnableOpt
    "enables nixos generation garbage collection";

  config = mkIf cfg.enable {
    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };
}
