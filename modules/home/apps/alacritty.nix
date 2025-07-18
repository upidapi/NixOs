{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.apps.alacritty;
in {
  options.modules.home.apps.alacritty =
    mkEnableOpt "Whether or not to enable alacritty, a terminal emulator";

  config = mkIf cfg.enable {
    # i dont think this is actually the default settings
    # https://github.com/TwiggieSmallz/Default-Alacritty-TOML-Config/blob/main/alacritty.toml

    programs.alacritty = {
      enable = true;
      settings = {
        # set by stylix
        # font.size = 10;
      };
    };

    home.sessionVariables = {
      TERMINAL = "alacritty";
    };
  };
}
