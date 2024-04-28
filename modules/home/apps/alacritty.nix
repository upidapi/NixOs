{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (my_lib.opt) mkEnableOpt mkOpt;
  cfg = config.modules.home.apps.alacritty;
in {
  options.modules.home.apps.alacritty =
    mkEnableOpt "Whether or not to enable alacritty, a terminal emulator";

  config = mkIf cfg.enable {
    # i dont think this is actualy the defautl settings
    # https://github.com/TwiggieSmallz/Default-Alacritty-TOML-Config/blob/main/alacritty.toml

    programs.alacritty = {
      enable = true;
      settings = {
        font.size = 10;
      };
    };

    home.sessionVariables = {
      TERMINAL = "alacritty";
    };
  };
}
