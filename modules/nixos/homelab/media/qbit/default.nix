{
  config,
  lib,
  mlib,
  const,
  inputs',
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

  # qbit doesnt start when lockfile exists
  #   https://github.com/qbittorrent/qBittorrent/issues/24164
  #   rm /var/lib/qBittorrent/qBittorrent/config/lockfile

  # This randomly broke, indexers started showing
  #   "device or resource busy" no config no nothing
  #   fixed by disabling the netns
  # Regenerating the proton wg config fixed it
  #   I guess they silently changed something that broke my setup
  #   Fml, spent too many hours on this
  config = mkIf cfg.enable {
    systemd.tmpfiles.settings = {
      "qbit-dir-create" = {
        "/raid/media/torrents".d = {
          user = "qbittorrent";
          group = "media";
          mode = "771";
        };
        "/raid/media/torrents".Z = {
          user = "qbittorrent";
          group = "media";
          mode = "771";
        };

        "/raid/media/torrents/tv".d = {
          user = "qbittorrent";
          group = "media";
          mode = "771";
        };
        "/raid/media/torrents/movies".d = {
          user = "qbittorrent";
          group = "media";
          mode = "771";
        };
        "/raid/media/torrents/misc".d = {
          user = "qbittorrent";
          group = "media";
          mode = "771";
        };
        "/raid/media/torrents/tmp".d = {
          user = "qbittorrent";
          group = "media";
          mode = "771";
        };
      };
    };

    sops.secrets = {
      "radarr/api-key_qbit" = {
        key = "radarr/api-key";
        owner = config.services.qbittorrent.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
      "sonarr/api-key_qbit" = {
        key = "sonarr/api-key";
        owner = config.services.qbittorrent.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
    };
    services.qbittorrent = {
      enable = true;
      group = "media";
      profileDir = "/var/lib/qBittorrent";

      # package = inputs'.nixpkgs-stable.legacyPackages.qbittorrent-nox;
      # package = inputs.qbit.legacyPackages.${pkgs.system}.qbittorrent-nox;
      webuiPort = ports.qbit;
      serverConfig = {
        LegalNotice.Accepted = true;

        Network.PortForwardingEnabled = false;

        AutoRun = {
          enabled = true;
          program = let
            radarrApiKeyFile = config.sops.secrets."radarr/api-key_qbit".path;
            sonarrApiKeyFile = config.sops.secrets."sonarr/api-key_qbit".path;
            x = pkgs.writeShellScript "qbit-sync-port" ''
              #!/usr/bin/env bash
              # shellcheck shell=bash

              RADARR_URL="http://127.0.0.1:${toString ports.radarr}"
              RADARR_API_KEY="$(cat "${radarrApiKeyFile}")"
              RADARR_CATEGORY="radarr"

              SONARR_URL="http://127.0.0.1:${toString ports.sonarr}"
              SONARR_API_KEY="$(cat "${sonarrApiKeyFile}")"
              SONARR_CATEGORY="tv-sonarr"

              # qBittorrent parameters:
              # %N = Torrent name ($1), %L = Category ($2)
              TORRENT_NAME="$1"
              CATEGORY="$2"

              case "$CATEGORY" in
                  "$RADARR_CATEGORY")
                      curl -s -X POST "$RADARR_URL/api/v3/command" \
                           -H "X-Api-Key: $RADARR_API_KEY" \
                           -H "Content-Type: application/json" \
                           -d '{"name": "CheckForFinishedDownload"}' > /dev/null 2>&1
                      ;;

                  "$SONARR_CATEGORY")
                      curl -s -X POST "$SONARR_URL/api/v3/command" \
                           -H "X-Api-Key: $SONARR_API_KEY" \
                           -H "Content-Type: application/json" \
                           -d '{"name": "CheckForFinishedDownload"}' > /dev/null 2>&1
                      ;;

                  *)
                      # Torrent from another category or untagged; do nothing
                      exit 0
                      ;;
              esac

              exit 0
            '';
          in "${x} \\\"%N\\\" \\\"%L\\\"";
        };

        BitTorrent.Session = {
          DefaultSavePath = "/raid/media/torrents/misc";

          TempPathEnabled = true;
          TempPath = "/raid/media/torrents/tmp";

          DisableAutoTMMByDefault = false;
          DisableAutoTMMTriggers = {
            CategoryChanged = false;
            CategorySavePathChanged = false;
            DefaultSavePathChanged = false;
          };

          # prevent qbit from eating all my ram
          # which in turn causes system lag / unresponsiveness
          DiskIOReadMode = "DisableOSCache";

          # https://www.reddit.com/search/?q=Circumventing%20proton%20vpn%20ddos&cId=8f3a490d-e9e2-4649-84cf-92ee353b4968&iId=39143626-1f98-46d4-a015-03074afd4bc7
          # "DHT will trigger ProtonVPN Anti-ddos, disable it."
          DHTEnabled = false;
          # PeXEnabled = false;
          # LSDEnabled = false;

          # prefer to seed to fastest peers
          # https://www.reddit.com/r/qBittorrent/s/EZGMJKCSGR

          ChokingAlgorithm = "RateBased";

          # disable limits
          MaxConnections = -1;
          MaxConnectionsPerTorrent = -1;
          MaxUploads = -1;
          MaxUploadsPerTorrent = -1;

          MaxActiveDownloads = 10;
          MaxActiveUploads = 10;

          MaxActiveTorrents = 1000;

          BTProtocol = "TCP";

          IgnoreLimitsOnLAN = true;
          IgnoreSlowTorrentsForQueueing = true;
          SlowTorrentsDownloadRate = 500;
          SlowTorrentsUploadRate = 500;
        };

        Preferences.WebUI = {
          Port = ports.qbit;
          Username = "admin";

          BanDuration = 60;
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

    systemd = {
      timers.qbit-seed-prio = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "15m";
        };
      };

      services = {
        qbittorrent = {
          # disabling this "fixes" the issue
          vpnConfinement = enableAnd {
            vpnNamespace = "proton";
          };

          serviceConfig = {
            UMask = 006;
            LimitNOFILE = 65535;
          };
        };

        "qbit-seed-prio" = {
          enable = true;

          # vpnConfinement = enableAnd {
          #   vpnNamespace = "proton";
          # };

          after = ["qbittorrent.service"];
          wantedBy = ["multi-user.target"];
          path = [];
          serviceConfig = {
            User = "root";
            Group = "media";

            ExecStart = let
              pswFile = config.sops.secrets."qbit/password".path;
              url = "http://${ips.proton}:${toString ports.qbit}";
            in
              pkgs.writers.writePython3 "seed_prio" {
                doCheck = false;
                libraries = [pkgs.python3Packages.qbittorrent-api];
              }
              # python
              ''
                import qbittorrentapi

                # prioritise torrents that have not been seeded for 7d
                # this is to make sure i do not get HnRs

                with open("${pswFile}") as f:
                    psw = f.read()

                qbt = qbittorrentapi.Client(
                    host="${url}", 
                    username="admin", 
                    password=psw,
                )
                for attempt in range(12):
                    try:
                        qbt.auth_log_in()
                        break
                    except qbittorrentapi.exceptions.APIConnectionError:
                        time.sleep(5)
                else:
                    raise RuntimeError("Failed to reach WebUI")

                SEED_TIME = 10 * 24 * 60 * 60 # should be 7d, use 10d for safety

                under_7d = []
                over_7d = []

                for t in qbt.torrents_info():
                    if t.state_enum.is_complete:
                        if t.seeding_time < SEED_TIME:
                            under_7d.append(t.hash)
                        else:
                            over_7d.append(t.hash)

                if over_7d:
                    qbt.torrents_bottom_priority(torrent_hashes=over_7d)
                if under_7d:
                    qbt.torrents_top_priority(torrent_hashes=under_7d)

                print(
                    f"Updated queue: {len(under_7d)} prioritized, {len(over_7d)} demoted to back."
                )
              '';
          };
        };

        "qbit-sync-port" = {
          enable = true;

          vpnConfinement = enableAnd {
            vpnNamespace = "proton";
          };

          after = ["qbittorrent.service"];
          wantedBy = ["multi-user.target"];
          path = [pkgs.libnatpmp pkgs.curl pkgs.iptables];
          serviceConfig = {
            User = "root";
            Group = "media";

            ExecStart = let
              pswFile = config.sops.secrets."qbit/password".path;
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

                last_vpn_port=

                cleanup() {
                    if [[ -n "$last_vpn_port" ]]; then
                      iptables -D INPUT 1 -p tcp --dport "$last_vpn_port" -j ACCEPT
                    fi
                }

                trap "cleanup" EXIT

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
                        # proton vpn doesn't listen to lifetime (always 60)
                        # nor public port
                        natpmpc -a 1 0 tcp 60 -g 10.2.0.1 |
                            grep 'Mapped public port' |
                            sed -E 's/.*Mapped public port ([0-9]+) protocol TCP to local port [0-9]+ lifetime [0-9]+/\1/'
                    )

                    if [[ -z "$vpn_port" ]]; then
                        red "Failed to get vpn port"
                        return
                    fi

                    if [[ "$vpn_port" != "$last_vpn_port" ]]; then
                      echo "External vpn port updated $active_port => $vpn_port"

                      # map public port to same internal port
                      natpmpc -a 1 "$vpn_port" tcp 60 -g 10.2.0.1 > /dev/null

                      iptables -I INPUT 1 -p tcp --dport "$vpn_port" -j ACCEPT
                      if [[ -n "$last_vpn_port" ]]; then
                        iptables -D INPUT 1 -p tcp --dport "$last_vpn_port" -j ACCEPT
                      fi

                      last_vpn_port="$vpn_port"
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
                            echo "Updated qbit port $active_port => $vpn_port"
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
    };
  };
}
