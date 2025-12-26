{
  config,
  lib,
  mlib,
  const,
  pkgs,
  self,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.homelab.wg-easy;
  inherit (const) ports;
in {
  options.modules.nixos.homelab.wg-easy = mkEnableOpt "";

  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "wg-easy.upidapi.dev".extraConfig = ''
        import harden_headers

        reverse_proxy :${toString ports.wg-easy}
      '';
    };

    boot.kernelModules = [
      "wireguard"
      "ip_tables"
      "iptable_nat"
      "ip6_tables"
      "ip6table_nat"
    ];

    networking = {
      nat = {
        enable = true;
        externalInterface = "wg0";
        internalInterfaces = ["lo0"];
      };
      firewall = {
        allowedUDPPorts = [
          const.ports.wireguard
        ];
        allowedTCPPorts = [
          const.ports.wg-easy
        ];
      };
    };

    systemd.tmpfiles.rules = [
      "d '/var/lib/wg-easy' 0700 - - - -"
      # "d '/etc/wireguard' 0700 - - - -"
    ];

    # check if service is up
    # nc -w5 -z -v 127.0.0.1 51820

    # force to resetup each time
    systemd.services = let
      containerCfg = config.virtualisation.oci-containers.containers.wg-easy;
    in {
      "${containerCfg.serviceName}-pre" = {
        serviceConfig.ExecStart =
          pkgs.writeShellScript
          "${containerCfg.serviceName}-pre" ''
            DB_PATH="/var/lib/wg-easy/wg-easy.db"
            if [ -f "$DB_PATH" ]; then
              ${pkgs.sqlite}/bin/sqlite3 "$DB_PATH" '
                UPDATE general_table SET setup_step = 1;
                DELETE FROM users_table;
                DELETE FROM sqlite_sequence WHERE name = "users_table";
              '
            fi
          '';
      };

      ${containerCfg.serviceName} = {
        requires = ["${containerCfg.serviceName}-pre.service"];
        after = ["${containerCfg.serviceName}-pre.service"];
      };
    };

    sops.secrets."wg-easy/password" = {
      sopsFile = "${self}/secrets/server.yaml";
    };
    sops.templates."wg-easy-env".content = ''
      INIT_PASSWORD=${config.sops.placeholder."wg-easy/password"}
    '';

    # you have to restart manually when you make changes
    # scl restart podman-wg-easy.service
    virtualisation = {
      oci-containers = {
        # backend = "docker";
        containers = {
          wg-easy = {
            hostname = "wg-easy";
            image = "ghcr.io/wg-easy/wg-easy:15";
            volumes = [
              "/run/current-system/kernel-modules:/lib/modules:ro"
              "/var/lib/wg-easy:/etc/wireguard"
            ];

            ports = [
              "${toString ports.wireguard}:${toString ports.wireguard}/udp"
              "${toString ports.wg-easy}:${toString ports.wg-easy}/tcp"
            ];
            capabilities = {
              NET_ADMIN = true;
              SYS_MODULE = true;
              NET_RAW = true;
            };
            extraOptions = [
              "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
              "--sysctl=net.ipv4.ip_forward=1"
              "--sysctl=net.ipv6.conf.all.disable_ipv6=0"
              "--sysctl=net.ipv6.conf.all.forwarding=1"
              "--sysctl=net.ipv6.conf.default.forwarding=1"
            ];
            environment = {
              PORT = toString ports.wg-easy; # webgui
              # HOST = "0.0.0.0";
              INSECURE = "true";
              DISABLE_IPV6 = "false";

              # wg config
              INIT_ENABLED = "true";
              INIT_USERNAME = "admin";
              # INIT_PASSWORD = "TestTestTest";
              INIT_HOST = "vpn.upidapi.dev";
              INIT_PORT = toString ports.wireguard;
            };

            environmentFiles = [
              config.sops.templates."wg-easy-env".path
            ];
          };
        };
      };
    };
  };
}
