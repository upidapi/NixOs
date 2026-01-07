{
  config,
  lib,
  mlib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.misc.appimage;
in {
  options.modules.nixos.misc.appimage = mkEnableOpt "";

  # make appimage's executable
  # ./program.AppImage

  config = mkIf cfg.enable {
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
    # old method
    # boot.binfmt.registrations.appimage = {
    #   wrapInterpreterInShell = false;
    #   interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    #   recognitionType = "magic";
    #   offset = 0;
    #   mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    #   magicOrExtension = ''\x7fELF....AI\x02'';
    # };
  };
}
