{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.os.env.paths;
in {
  options.modules.nixos.os.env.paths = mkEnableOpt "enable completions for eg sys pkgs";

  config = mkIf cfg.enable {
    # enable completions for system packages
    # and other stuff

    environment.pathsToLink = [
      "/share/zsh" # zsh completions
      "/share/bash-completion" # bash completions
      "/share/nix-direnv" # direnv completions
      "/share/nushell" # direnv completions
    ];
  };
}
