{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.nix.cachix;
in {
  options.modules.nixos.nix.cachix =
    mkEnableOpt "enables some nixos caching servers";

  config = mkIf cfg.enable {
    # defines places where nix can fetch cached programs

    nix.settings = {
      substituters = [
        "https://cuda-maintainers.cachix.org"
        "https://cache.nixos.org/"
        "https://hyprland.cachix.org"
        "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };
  };
}
