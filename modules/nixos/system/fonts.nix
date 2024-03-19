{
  pkgs,
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt mkOpt;
  inherit (lib) mkIf types;
  cfg = config.modules.nixos.system.fonts;
in {
  options.modules.nixos.system.fonts =
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

    fonts.packages = with pkgs;
      [
        # noto-fonts
        # noto-fonts-cjk-sans
        # noto-fonts-cjk-serif
        # noto-fonts-emoji

        material-symbols
        (nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
      ]
      ++ cfg.fonts;
  };
}
