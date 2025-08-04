{
  config,
  mlib,
  lib,
  ...
}: let
  inherit (mlib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.nix.cachix;
in {
  options.modules.nixos.nix.cachix =
    mkEnableOpt "enables some nixos caching servers";

  config = mkIf cfg.enable {
    # defines places where nix can fetch cached programs

    nix.settings = {
      substituters = [
        # tons of unfree pkgs and other stuff, eg cuda pkgs
        "https://nix-community.cachix.org"
        # "https://cuda-maintainers.cachix.org" # not needed
        "https://cache.nixos.org/"
        "https://hyprland.cachix.org"
        "https://devenv.cachix.org"
        "https://ai.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        # "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
      ];
    };
  };
}
