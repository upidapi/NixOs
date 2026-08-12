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
    systemd.services = let
      mkMcServer = dir: pk: script: {
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
        path = pk;
        serviceConfig = {
          User = "minecraft";
          Group = "minecraft";

          WorkingDirectory = dir;
          ExecStart = pkgs.writeShellScript "run-mc-server" script;
        };
      };
    in {
      # "mc-server-SAM-1b" = mkMcServer "/var/lib/minecraft/SAM-1b-so" ''
      #   java -jar fabric-server-launch.jar nogui --port ${toString ports.mc-server}
      # '';
      #
      # "mc-server-nore" = mkMcServer "/var/lib/minecraft/nore" ''
      #   java -jar fabric-server-launch.jar nogui --port ${toString ports.mc-server-b}
      # '';

      "mc-server-sam" =
        mkMcServer
        "/var/lib/minecraft/sam-person"
        [pkgs.openjdk25_headless] ''
          java -jar fabric-server-launch.jar nogui \
            --port ${toString ports.mc-server-c}
        '';
    };
  };
}
