{
  config,
  pkgs,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.cli-apps.bitwarden;
in {
  options.modules.home.cli-apps.bitwarden =
    mkEnableOpt "Whether or not to enable bitwarden";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bitwarden
      bitwarden-cli
    ];
  };
}
