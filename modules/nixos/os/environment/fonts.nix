{
  pkgs,
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt mkOpt;
  inherit (lib) mkIf types;
  cfg = config.modules.nixos.os.environment.fonts;
in {
  options.modules.nixos.os.environment.fonts =
    mkEnableOpt "adds fonts to the system"
    // {
      fonts =
        mkOpt
        (types.listOf types.package) []
        "Custom font packages to install.";
    };

  config = mkIf cfg.enable {
    environment.variables = {
      # Enable icons in tooling since we have nerdfonts.
      LOG_ICONS = "true";
    };

    environment.systemPackages = with pkgs; [font-manager];

    fonts.packages =
      (with pkgs; [
        # noto-fonts
        # noto-fonts-cjk-sans
        # noto-fonts-cjk-serif
        # noto-fonts-emoji  # i think this breaks other glyphs, for example the lock turns into some red thingy

        material-symbols
        (nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
      ])
      ++ cfg.fonts;
  };
}
