{
  config,
  lib,
  mlib,
  pkgs,
  # self',
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.homelab.games.minecraft;
in {
  options.modules.nixos.homelab.games.minecraft = mkEnableOpt "";

  config = mkIf cfg.enable {
    # environment.systemPackages = [
    #   self'.packages.mcman
    # ];
    systemd.tmpfiles.settings.mcServer = {
      "/var/lib/minecraft"."d" = {
        mode = "700";
        user = "root";
        group = "root";
      };
    };
    systemd.services."mc-server" = {
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      path = [pkgs.jre pkgs.jre8];
      serviceConfig = {
        # User = "upidapi";
        # Group = "users";

        # TODO: fix, this shouldnt be hermitcraft modpack
        WorkingDirectory = "/var/lib/minecraft/hermitcraft";
        ExecStart = pkgs.writeShellScript "run-impostor-prod" ''
          java -jar fabric-server-launch.jar nogui
        '';
      };
    };
  };
}
