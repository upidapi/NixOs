{
  config,
  lib,
  my_lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.apps.spotify;

  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in {
  options.modules.home.apps.spotify =
    mkEnableOpt
    "Whether or not to enable spotify.";

  # import the flake's module for your system
  imports = [inputs.spicetify-nix.homeManagerModules.default];

  config = mkIf cfg.enable {
    # allow spotify to be installed if you don't have unfree enabled already
    # wouldn't do anything? since useGlobalPkgs is enabled
    # nixpkgs.config.allowUnfreePredicate = pkg:
    #   builtins.elem (lib.getName pkg) [
    #     "spotify"
    #   ];

    programs.spicetify = {
      enable = true;
      # theme = spicePkgs.themes.catppuccin;
      # colorScheme = "mocha";

      enabledExtensions = with spicePkgs.extensions; [
        fullAppDisplay
        shuffle # shuffle+ (special characters are sanitized out of ext names)
        # hidePodcasts
      ];
    };
  };
}
