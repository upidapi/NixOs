{
  config,
  lib,
  my_lib,
  self,
  ...
}: let
  inherit (lib) mkIf drop;
  inherit (my_lib.opt) mkEnableOpt;
  inherit (builtins) listToAttrs elemAt foldl';
  cfg = config.modules.nixos.os.networking.wifi;
in {
  options.modules.nixos.os.networking.wifi =
    mkEnableOpt
    "enables wifi for the system";

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

      # declaratively config network connections
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
              wifi-security = {
                auth-alg = "open";
                key-mgmt = "wpa-psk";
                psk = "${psk}";
              };
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
            listToAttrs (
              map (wifiData: let
                get = elemAt wifiData;
                mkWifi = get 0;
                ssid = get 1;
              in {
                # in practice this is ignored but it has to have some key
                name = "${ssid}";
                value = foldl' (a: b: (a b)) mkWifi (drop 1 wifiData);
              })
              x
            );
        in
          mergeWifis [
            # NOTE: env vars cant start with number :)

            # [mkOpenWifi "Vannarps Bussarna 1"]
            [mkWPA2WiFi "$SSID_1" "$PSK_1"]
            [mkWPA2WiFi "$SSID_2" "$PSK_2"]
            [mkWPA2WiFi "$SSID_3" "$PSK_3"]
            [mkWPA2WiFi "$SSID_4" "$PSK_4"]
            [mkWPA2WiFi "$SSID_5" "$PSK_5"]
          ]
          // {
            # add if i get a eduroam login
            # eduroam = {
            #   connection = {
            #     id = "eduroam";
            #     uuid = "74c15b1e-64d6-4eb8-86fc-8b683157b497";
            #     type = "802-11-wireless";
            #   };
            #   "802-11-wireless" = {
            #     ssid = "eduroam";
            #     security = "802-11-wireless-security";
            #   };
            #   "802-11-wireless-security" = {
            #     key-mgmt = "wpa-eap";
            #     proto = "rsn";
            #     pairwise = "ccmp";
            #     group = "ccmp;tkip";
            #   };
            #   "802-1x" = {
            #     eap = "peap";
            #     phase2-auth = "mschapv2";
            #     ca-cert = "${./eduroam-chalmers.crt}";
            #     altsubject-matches = "DNS:eduroam.chalmers.se";
            #     identity = "$EDUROAM_IDENTITY";
            #     password = "$EDUROAM_PASSWORD";
            #   };
            #   ipv4.method = "auto";
            #   ipv6.method = "auto";
            # };
          };
      };
    };
  };
}
