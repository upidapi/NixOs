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
    mkEnableOpt "Whether or not to enable alacritty, a terminal emulator"
    // {
      font-size = mkOpt types.int 10 "the font size, see code for more info";
    };

  config = mkIf cfg.enable {
    # i dont think this is actualy the defautl settings
    # https://github.com/TwiggieSmallz/Default-Alacritty-TOML-Config/blob/main/alacritty.toml

    programs.alacritty = {
      enable = true;
      settings = {
        # i think the defult is 12
        # But this doesn't render the same way on my devices
        # On (my) laptop 11 and 10 is the same but 11 is bold
        # On (my) pc 10 and 9 is the same but 10 is bold
        # and thease two are the same (10 on my laptop == 9 on my pc)

        # I prefer the bold text, so 11 on my pc, 10 on my laptop
        # TODO: find some better way to do it
        font.size = cfg.font-size;
      };
    };

    home.sessionVariables = {
      TERMINAL = "alacritty";
    };
  };
}
