{
  config,
  lib,
  mlib,
  self,
  const,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (const) ports ips;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.networking.vpn.namespaces;
in {
  options.modules.nixos.networking.vpn.namespaces =
    (mkEnableOpt "")
    // {
      mullvad = lib.mkEnableOption "";
      proton = lib.mkEnableOption "";
    };

  imports = [
    inputs.vpn-confinement.nixosModules.default
  ];

  config = mkIf cfg.enable {
    sops.secrets = {
      "mullvad-wg" = {
        sopsFile = "${self}/secrets/mullvad-wg";
        format = "binary";
      };
      "proton-wg" = {
        sopsFile = "${self}/secrets/proton-wg";
        format = "binary";
      };
    };

    # REF: https://github.com/simonalveteg/nixos-config/blob/906c5c5f0e61dde288a2ec6af06227b4d3ae512a/modules/server/default.nix#L6
    vpnNamespaces = rec {
      proton =
        mullvad
        // {
          enable = cfg.proton;
          wireguardConfigFile = config.sops.secrets.proton-wg.path;
          namespaceAddress = ips.proton;
        };
      mullvad = {
        enable = cfg.mullvad;
        wireguardConfigFile = config.sops.secrets.mullvad-wg.path;
        # The address at which the confined services will be accessible.
        namespaceAddress = ips.mullvad;
        accessibleFrom = [
          "192.168.0.0/16"
          "10.0.0.0/8"
          "127.0.0.1/32"
        ];
        portMappings = let
          passthru = p: {
            from = p;
            to = p;
          };
        in [
          (passthru ports.qbit)
          (passthru ports.sonarr)
          (passthru ports.radarr)
        ];
        openVPNPorts = [
          # is this needed?
          # {
          #   port = 58846; # Peer port.
          #   protocol = "both";
          # }
        ];
      };
    };
  };
}
