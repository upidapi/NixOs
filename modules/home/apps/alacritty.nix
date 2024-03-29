{
  config,
  pkgs,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.apps.alacritty;
in {
  options.modules.home.apps.alacritty =
    mkEnableOpt
    "Whether or not to enable alacritty, a terminal emulator";

  config.home = mkIf cfg.enable {
    packages = [
      pkgs.alacritty
    ];

    sessionVariables = {
      TERMINAL = "alacritty";
    };
  };
}
