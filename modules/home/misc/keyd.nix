{
  config,
  lib,
  my_lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.misc.keyd;
in {
  options.modules.home.misc.keyd = mkEnableOpt "enable compat for keyd";

  # config = mkIf cfg.enable {
  #   home.file.".XCompose".source = "${pkgs.keyd}/share/keyd/keyd.compose";
  # };
}
