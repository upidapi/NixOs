{
  config,
  lib,
  my_lib,
  self,
  ...
}: let
  inherit (lib) mkIf drop traceVal;
  inherit (my_lib.opt) mkEnableOpt;
  inherit (builtins) listToAttrs elemAt foldl';
  cfg = config.modules.nixos.os.networking;
in {
  options.modules.nixos.os.networking = mkEnableOpt "enables networking for the system";

  imports = [
    ./firewall
    ./openssh.nix
  ];

  config = mkIf cfg.enable {
    networking.hostName = config.modules.nixos.meta.host-name;
    # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    sops.secrets."network-manager-env" = {
      sopsFile = "${self}/secrets/shared.yaml";
    };

    networking.networkmanager = {
      enable = true;
      ensureProfiles = {
        environmentFiles = [config.sops.secrets."network-manager-env".path];

        # ref: https://github.com/alyraffauf/nixcfg/blob/master/hosts/common/wifi.nix
        # quickly convert nm files to nix: https://github.com/janik-haag/nm2nix
        profiles = let
          mkOpenWiFi = ssid: {
            connection.id = "${ssid}";
            connection.type = "wifi";
            ipv4.method = "auto";
            ipv6.addr-gen-mode = "default";
            ipv6.method = "auto";
            wifi.mode = "infrastructure";
            wifi.ssid = "${ssid}";
          };

          mkWPA2WiFi = ssid: psk: (
            (mkOpenWiFi ssid)
            // {
              wifi-security.auth-alg = "open";
              wifi-security.key-mgmt = "wpa-psk";
              wifi-security.psk = "${psk}";
            }
          );

          mkEAPWiFi = ssid: identity: pass: auth: (
            (mkOpenWiFi ssid)
            // {
              "802-1x".eap = "peap;";
              "802-1x".identity = "${identity}";
              "802-1x".password = "${pass}";
              "802-1x".phase2-auth = "${auth}";
              wifi-security.auth-alg = "open";
              wifi-security.key-mgmt = "wpa-eap";
            }
          );

          mergeWifis = x:
            traceVal (listToAttrs (
              map (wifiData: let
                get = elemAt wifiData;
                mkWifi = get 0;
                ssid = get 1;
              in {
                # in practice this is ignored but it has to have some key
                name = "${ssid}";
                value = traceVal (foldl' (a: b: (a b)) mkWifi (drop 1 wifiData));
              })
              x
            ));
        in
          mergeWifis [
            # [mkOpenWifi "Vannarps Bussarna 1"]
            [mkWPA2WiFi "$1_SSID" "$1_PSK"]
            [mkWPA2WiFi "$2_SSID" "$2_PSK"]
            [mkWPA2WiFi "$3_SSID" "$3_PSK"]
          ];
      };
    };
  };
}
