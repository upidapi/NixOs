{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.virtualization.vfio;
in {
  options.modules.nixos.os.virtualization.vfio =
    mkEnableOpt "";

  imports = [./base.nix];

  config = mkIf cfg.enable {
    virtualisation.vfio = {
      devices = [
        "10de:2182"
        "10de:1aeb"
        "10de:1aec"
        "10de:1aed"
      ];
    };
  };
}
