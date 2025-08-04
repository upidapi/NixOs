# REF: https://unix.stackexchange.com/questions/522822/different-methods-to-run-a-non-nixos-executable-on-nixos
/*
appimage-run

nix-shell -p steam-run --run "steam-run ./the-binary"

nix run github:thiagokokada/nix-alien -- yourprogram
*/
{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib.opt) mkEnableOpt;
  cfg = config.modules.nixos.os.misc.nix-ld;
in {
  options.modules.nixos.os.misc.nix-ld = mkEnableOpt "";

  config = mkIf cfg.enable {
    programs.nix-ld.enable = true;
  };
}
