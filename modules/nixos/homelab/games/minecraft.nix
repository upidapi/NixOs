{
  config,
  lib,
  mlib,
  pkgs,
  # self',
  const,
  ...
}: let
  inherit (lib) mkIf;
  inherit (const) ports;
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
    systemd.services = {
      "mc-server" = {
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
        path = [pkgs.jre pkgs.jre8];
        serviceConfig = {
          User = "minecraft";
          Group = "minecraft";

          WorkingDirectory = "/var/lib/minecraft/SAM-1b-so";
          ExecStart = pkgs.writeShellScript "run-mc-server" ''
            java -jar fabric-server-launch.jar nogui --port ${toString ports.mc-server}
          '';
        };
      };
      "mc-server-b" = {
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
        path = [pkgs.jre pkgs.jre8];
        serviceConfig = {
          User = "minecraft";
          Group = "minecraft";

          WorkingDirectory = "/var/lib/minecraft/nore";
          ExecStart = pkgs.writeShellScript "run-mc-server" ''
            java -jar fabric-server-launch.jar nogui --port ${toString ports.mc-server-b}
          '';
        };
      };
    };
  };
}
