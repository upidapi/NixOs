{
  config,
  lib,
  mlib,
  const,
  pkgs,
  self,
  ...
}: let
  inherit (const) ports ips;
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt enableAnd;
  cfg = config.modules.nixos.homelab.media.qbit;
in {
  options.modules.nixos.homelab.media.qbit = mkEnableOpt "";

  config = mkIf cfg.enable {
    systemd.services.qbittorrent.vpnConfinement = enableAnd {
      vpnNamespace = "proton";
    };

    services.qbittorrent = {
      enable = true;
      group = "media";
      # package = inputs.qbit.legacyPackages.${pkgs.system}.qbittorrent-nox;
      serverConfig = {
        LegalNotice.Accepted = true;
        BitTorrent.Session = {
          DefaultSavePath = "/raid/media/torrents";
          # TempPath = "/raid/media/torrents/tmp";

          # Port = 43361; # should be port forwarded

          # disable limits
          MaxConnections = -1;
          MaxConnectionsPerTorrent = -1;
          MaxUploads = -1;
          MaxUploadsPerTorrent = -1;

          MaxActiveDownloads = 10;
          MaxActiveTorrents = 50;
          MaxActiveUploads = 10;

          BTProtocol = "TCP";

          IgnoreLimitsOnLAN = true;
          IgnoreSlowTorrentsForQueueing = true;
          SlowTorrentsDownloadRate = 500;
          SlowTorrentsUploadRate = 500;
        };

        Preferences.WebUI = {
          Port = ports.qbit;
          Username = "admin";

          BanDuration = 300;
          MaxAuthenticationFailCount = 10;
          SessionTimeout = 60 * 60 * 24 * 30; # logout after a month

          # Use gen-hash.sh generate
          Password_PBKDF2 = "@ByteArray(TZ2O65dP76xf7p9U8tC4mg==:rEf5zTudNuXk7f8gjPjdZaigeFgRkxK1Gvn/YM4BOb3uHInTOTHJI1BS1pzdBHWrbwM0TG0ehFFRodb/DNp2Kw==)";
        };
      };
    };
    sops.secrets = {
      "qbit/password" = {
        key = "qbit/password";
        owner = config.services.qbittorrent.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
    };

    systemd.services."qbit-sync-port" = {
      after = ["qbittorrent.service"];
      wantedBy = ["multi-user.target"];
      path = [pkgs.libnatpmp];
      serviceConfig = {
        User = "qbittorrent";
        Group = "media";

        ExecStart = let
          pswFile = config.sops.secrets."qbit/password_declarr".path;
          url = "http://${ips.proton}:${toString ports.qbit}";
        in
          pkgs.writeShellScript "qbit-sync-port" ''
            #!/usr/bin/env bash
            # shellcheck shell=bash

            # REF: https://gist.github.com/KaBankz/c5a08845e3c64fbae8053dc7d28f8191
            # REF: https://bjarne.verschorre.be/blog/port-forwarding-proton-vpn/

            QBITTORRENT_USERNAME="admin"
            QBITTORRENT_PASSWORD="$(cat ${pswFile})"
            QBITTORRENT_BASE_URL="${url}"

            QBITTORRENT_LOGIN_API_ENDPOINT="$QBITTORRENT_BASE_URL/api/v2/auth/login"
            QBITTORRENT_GET_PREFS_API_ENDPOINT="$QBITTORRENT_BASE_URL/api/v2/app/preferences"
            QBITTORRENT_SET_PREFS_API_ENDPOINT="$QBITTORRENT_BASE_URL/api/v2/app/setPreferences"

            RED="\e[31m"
            RESET="\e[0m"

            red() {
                echo -e "''${RED}$1''${RESET}"
            }

            throw() {
                red "$1"
                kill -s TERM "$TOP_PID"
            }

            sync_port() {
                qbittorrent_auth_cookie=$(
                    curl -si "$QBITTORRENT_LOGIN_API_ENDPOINT" \
                        --header "Referer: $QBITTORRENT_BASE_URL" \
                        --data "username=$QBITTORRENT_USERNAME&password=$QBITTORRENT_PASSWORD" |
                        grep -oP '(?<=set-cookie: )\S*(?=;)'
                )

                if [[ -z "$qbittorrent_auth_cookie" ]]; then
                    # may occur while qbittorrent is starting up
                    red "Failed to get qbit auth cookie"
                    return
                fi

                vpn_port=$(
                    natpmpc -a 1 0 tcp 60 -g 10.2.0.1 |
                        grep 'Mapped public port' |
                        sed -E 's/.*Mapped public port ([0-9]+) protocol TCP to local port [0-9]+ lifetime [0-9]+/\1/'
                )

                if [[ -z "$vpn_port" ]]; then
                    red "Failed to get vpn port"
                    return
                fi

                active_port=$(
                    curl -s "$QBITTORRENT_GET_PREFS_API_ENDPOINT" \
                        -b "$qbittorrent_auth_cookie" |
                        grep -oP '(?<="listen_port":)\d+(?=,)'
                )

                if [[ -z "$active_port" ]]; then
                    red "Failed to get current port"
                    return
                fi

                # echo "$qbittorrent_auth_cookie"
                # echo "$vpn_port"
                # echo "$active_port"

                if [[ "$vpn_port" != "$active_port" ]]; then
                    res=$(
                        curl -si "$QBITTORRENT_SET_PREFS_API_ENDPOINT" \
                            -b "$qbittorrent_auth_cookie" \
                            -XPOST \
                            -d "json={\"listen_port\":$vpn_port}" \
                            -o /dev/null \
                            -w "%{http_code}"
                    )

                    if [[ "$res" == "200" ]]; then
                        echo "Updated port $active_port => $vpn_port"
                    else
                        red "Failed to sync ports"
                    fi
                fi

            }

            sync_port

            while true; do
                sleep 30
                sync_port
            done
          '';
      };
    };
  };
}
