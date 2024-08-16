{
  config,
  pkgs,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.apps.spotify;
in {
  options.modules.home.apps.spotify = mkEnableOpt "Whether or not to enable spotify.";

  # TODO: spicefy
  config = mkIf cfg.enable {
    home.packages = [
      pkgs.spotify
    ];
  };
}
