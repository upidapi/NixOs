{
  config,
  lib,
  my_lib,
  pkgs,
  ports,
  self,
  inputs,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (my_lib.opt) mkEnableOpt enableAnd;
  cfg = config.modules.nixos.os.networking.mullvad;
in {
  options.modules.nixos.os.networking.mullvad =
    mkEnableOpt ""
    // {
      createNamespace = lib.mkOption {
        type = types.bool;
        default = false;
      };
    };

  imports = [
    inputs.vpn-confinement.nixosModules.default
  ];

  config = lib.mkMerge [
    (mkIf cfg.enable {
      services.mullvad-vpn = enableAnd {
        package = pkgs.mullvad-vpn;
      };
    })
    (mkIf cfg.createNamespace {
      sops.secrets."mullvad-wg" = {
        sopsFile = "${self}/secrets/mullvad-wg";
        format = "binary";
      };

      # REF: https://github.com/simonalveteg/nixos-config/blob/906c5c5f0e61dde288a2ec6af06227b4d3ae512a/modules/server/default.nix#L6
      vpnNamespaces.mullvad = {
        enable = true;
        wireguardConfigFile = config.sops.secrets.mullvad-wg.path;
        # The address at which the confined services will be accessible.
        namespaceAddress = "192.168.15.1";
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
    })
  ];
}
