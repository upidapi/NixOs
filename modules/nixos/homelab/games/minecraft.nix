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
    users.users.minecraft = {
      isSystemUser = true;
      group = "minecraft";
      # home = cfg.dataDir;
    };
    users.groups.minecraft = {};

    systemd.tmpfiles.settings.mcServer = {
      "/var/lib/minecraft"."d" = {
        mode = "770";
        user = "minecraft";
        group = "minecraft";
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
        WorkingDirectory = "/var/lib/minecraft/SAM-1b-so";
        ExecStart = pkgs.writeShellScript "run-mc-server" ''
          java -jar fabric-server-launch.jar nogui
        '';
      };
    };
  };
}
