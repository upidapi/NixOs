{
  config,
  lib,
  mlib,
  const,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.homelab.impostor;
in {
  options.modules.nixos.homelab.impostor = mkEnableOpt "";

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."games.upidapi.dev".extraConfig = ''
      reverse_proxy :${toString const.ports.impostor}
    '';

    systemd.services."imposor-game" = {
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        DevicePolicy = "closed";
        # breaks when dir is persisted via fuse mounts
        # DynamicUser = true;
        ExecStart = pkgs.writeShellScript ''
          cd /persist/system/home/upidapi/persist/prog/projects/impostor/;
          npm run build;
          PORT=7500 npm start
        '';
        # LockPersonality = true;
        # MemoryDenyWriteExecute = true;
        # PrivateDevices = true;
        # PrivateUsers = true;
        # ProtectClock = true;
        # ProtectControlGroups = true;
        # ProtectHostname = true;
        # ProtectKernelLogs = true;
        # ProtectKernelModules = true;
        # ProtectKernelTunables = true;
        # ProtectProc = "invisible";
        # RestrictAddressFamilies = [
        #   "AF_INET"
        #   "AF_INET6"
        # ];
        # RestrictNamespaces = true;
        # RestrictRealtime = true;
        # SystemCallArchitectures = ["native"];
        # SystemCallFilter = ["@system-service"];
        # StateDirectory = baseNameOf cfg.stateDirectory;
      };
    };
  };
}
