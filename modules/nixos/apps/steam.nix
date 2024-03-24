{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.apps.steam;
in {
  options.modules.nixos.apps.steam = mkEnableOpt "Whether or not to enable Steam.";
  # todo: fugure out how to set the game install dir ( make shure it works with impermanance)
  # https://github.com/jakehamilton/config/blob/d061040df2cb2c9b941f4c9f57a65e749a99a03e/modules/nixos/apps/steam/default.nix#L5

  # steam.enable also enables proton
  config.programs.steam = mkIf cfg.enable {
    enable = true;

    # Open ports in the firewall for Steam Remote Play
    remotePlay.openFirewall = true;

    # Open ports in the firewall for Source Dedicated Server
    dedicatedServer.openFirewall = true;
  };
}
