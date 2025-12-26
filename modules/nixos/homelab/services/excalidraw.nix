{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.homelab.excalidraw;
in {
  options.modules.nixos.homelab.services.excalidraw = mkEnableOpt "";

  # https://www.reddit.com/r/selfhosted/comments/1anbstg/excalidraw_self_host/
  # https://gist.github.com/tenekev/0e96895ff1789d7ce82aeec287487640
  # https://github.com/Someone0nEarth/excalidraw-self-hosted/blob/master/docker-compose.yml
  # https://github.com/IamTaoChen/excalidraw-demo
  # https://github.com/NixOS/nixpkgs/pull/421980
  config =
    mkIf cfg.enable {
    };
}
