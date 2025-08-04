{
  config,
  lib,
  mlib,
  pkgs,
  const,
  ...
}: let
  inherit (const) wg ports;
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.os.networking.wireguard;

  hostName = config.modules.nixos.meta.host-name;
  users = [
    "upinix-laptop"
    "upinix-pc"
    "upi-phone"
    "guest"
  ];
  wgIps = lib.pipe users [
    (lib.imap1 (i: h: {
      name = h;
      value = "10.100.0.${toString i}";
    }))
    lib.listToAttrs
  ];
in {
  # NOTE: not finished, might work might not, currently using wg-easy

  # maybe
  # https://www.privateproxyguide.com/tuning-wireguard-for-ultra-low-latency-connections/
  options.modules.nixos.os.networking.wireguard = {
    server = mkEnableOpt "";
    client = mkEnableOpt "";
  };

  config = lib.mkMerge [
    (mkIf cfg.server.enable {
      sops.secrets."wireguard/key" = {};

      networking = {
        nat = {
          enable = true;
          externalInterface = "eth0";
          internalInterfaces = ["wg0"];
        };
        firewall = {
          allowedUDPPorts = [ports.wireguard];
        };

        wireguard.enable = true;
        wireguard.interfaces = {
          wg0 = {
            # Determines the IP address and subnet of the server's end of the
            # tunnel interface.
            ips = ["${wgIps.${hostName}}/24"];

            # The port that WireGuard listens to. Must be accessible by the
            # client.
            listenPort = ports.wireguard;

            # This allows the wireguard server to route your traffic to the
            # internet and hence be like a VPN. for this to work you have to set
            # the dnsserver ip of your router (or dnsserver of choice) in your
            # clients
            postSetup = ''
              ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
            '';
            postShutdown = ''
              ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
            '';

            privateKeyFile = config.sops.secrets."wireguard/key".path;

            peers =
              map (h: {
                name = h;
                publicKey = wg.${h};
                allowedIPs = ["${wgIps.${h}}/32"];
              })
              users;
          };
        };
      };
    })

    (mkIf cfg.client.enable {
      sops.secrets."wireguard/key" = {};

      networking = {
        firewall = {
          allowedUDPPorts = [ports.wireguard];
        };
        # Enable WireGuard
        wireguard.enable = true;
        wireguard.interfaces = {
          wg0 = {
            # Determines the IP address and subnet of the client's end of the
            # tunnel interface.
            ips = ["${wgIps.${hostName}}/24"];
            listenPort = ports.wireguard;

            privateKeyFile = config.sops.secrets."wireguard/key".path;

            peers = [
              {
                # Public key of the server (not a file path).
                publicKey = wg.upinix-pc;

                # Forward all the traffic via VPN.
                allowedIPs = ["0.0.0.0/0"];
                # Or forward only particular subnets
                #allowedIPs = [ "10.100.0.1" "91.108.12.0/22" ];

                # Set this to the server IP and port.
                # ToDo: route to endpoint not automatically configured
                # https://wiki.archlinux.org/index.php/WireGuard#Loop_routing
                # https://discourse.nixos.org/t/solved-minimal-firewall-setup-for-wireguard-client/7577
                endpoint = "vpn.upidapi.dev:${toString ports.wireguard}";

                # Send keepalives every 25 seconds. Important to keep NAT tables alive.
                persistentKeepalive = 25;
              }
            ];
          };
        };
      };
    })
  ];
}
