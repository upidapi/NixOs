{
  config,
  lib,
  my_lib,
  const,
  self,
  pkgs,
  ...
}: let
  inherit (const) ports ips;
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.homelab.homepage;
in {
  options.modules.nixos.homelab.homepage = mkEnableOpt "";

  config = mkIf cfg.enable {
    sops.secrets."qbit/password_homepage" = {
      key = "qbit/password";
      sopsFile = "${self}/secrets/server.yaml";
    };

    sops.templates."homepage-env".content = ''
      HOMEPAGE_VAR_QBIT_PSW=${config.sops.placeholder."qbit/password_homepage"}
      HOMEPAGE_VAR_SONARR_KEY=${config.sops.placeholder."sonarr/api-key"}
      HOMEPAGE_VAR_RADARR_KEY=${config.sops.placeholder."radarr/api-key"}
      HOMEPAGE_VAR_PROWLARR_KEY=${config.sops.placeholder."prowlarr/api-key"}
    '';

    # needed for homepage dashboard ping
    systemd.services.homepage-dashboard.path = [pkgs.unixtools.ping];
    services = {
      caddy.virtualHosts = {
        # "upidapi.dev".extraConfig = ''
        # '';
        "upidapi.dev".extraConfig = ''
          import harden_headers

          reverse_proxy :${toString ports.homepage}
        '';
      };

      # REF: https://github.com/Cody-W-Tucker/nix-config/blob/804d2e768ceb469e020a42cfb0318c3171bd1c93/modules/server/homepage-dashboard.nix#L16
      # REF: https://github.com/wi11-holdsworth/dots/blob/499755444a6a5c7f0883355430461c45d34cdee2/modules/nixos/features/homepage-dashboard.nix#L25

      homepage-dashboard = {
        enable = true;
        environmentFile = config.sops.templates."homepage-env".path;
        listenPort = ports.homepage;
        openFirewall = false;
        allowedHosts = "upidapi.dev";
        settings = {
          title = "upidapi.dev";
          description = " ";

          background = "https://images.unsplash.com/photo-1502790671504-542ad42d5189?auto=format&fit=crop&w=2560&q=80";

          theme = "dark";
          color = "slate";
          cardBlur = "xs";

          disableUpdateCheck = true;
          hideVersion = true;

          target = "_blank"; # open in new tab

          statusStyle = "dot";

          layout = {
            Media = {
              header = true;
              style = "row";
              columns = 4;
            };
            "Media Managment" = {
              header = true;
              style = "row";
              columns = 4;
            };
            "Misc" = {
              header = true;
              style = "row";
              columns = 4;
            };
            "Local" = {
              header = true;
              style = "row";
              columns = 4;
            };
          };

          # quicklaunch = {
          #   searchDescription = true;
          #   hideInternetSearch = true;
          #   showSearchSuggestions = true;
          #   hideVisitURL = true;
          # };
        };
        widgets = [
          {
            datetime = {
              locale = "se";
              format = {
                timeStyle = "short";
                dateStyle = "short";
              };
            };
          }
          {
            resources = {
              cpu = true;
              memory = true;
              disk = "/";
            };
          }
        ];
        services = [
          {
            Media = [
              {
                Jellyfin = rec {
                  icon = "jellyfin";
                  description = "Media Server";
                  href = "https://jellyfin.upidapi.dev";
                  ping = href;
                };
              }
              {
                Jellyseerr = rec {
                  icon = "jellyseerr";
                  description = "Request Media Service";
                  href = "https://jellyseerr.upidapi.dev";
                  ping = href;
                };
              }
            ];
          }
          {
            "Media Managment" = [
              {
                Sonarr = rec {
                  icon = "sonarr.svg";
                  href = "http://sonarr.upidapi.dev";
                  ping = href;
                  widget = {
                    type = "sonarr";
                    url = "http://localhost:${toString ports.sonarr}";
                    key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
                    # enableQueue = true;
                  };
                };
              }
              {
                Radarr = rec {
                  icon = "radarr.svg";
                  href = "http://radarr.upidapi.dev";
                  ping = href;
                  widget = {
                    type = "radarr";
                    url = "http://localhost:${toString ports.radarr}";
                    key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
                    # enableQueue = true;
                  };
                };
              }
              {
                Prowlarr = rec {
                  icon = "prowlarr.svg";
                  href = "http://prowlarr.upidapi.dev";
                  ping = href;
                  widget = {
                    type = "prowlarr";
                    url = "http://localhost:${toString ports.prowlarr}";
                    key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
                  };
                };
              }
              {
                qBittorrent = rec {
                  icon = "qbittorrent.svg";
                  href = "http://qbit.upidapi.dev";
                  ping = href;
                  widget = {
                    type = "qbittorrent";
                    url = "http://${ips.mullvad}:${toString ports.qbit}";
                    username = "admin";
                    password = "{{HOMEPAGE_VAR_QBIT_PSW}}";
                  };
                };
              }
            ];
          }
          {
            Misc = [
              {
                "Paste Bin" = rec {
                  icon = "hastypaste.svg";
                  description = "A private paste bin";
                  href = "http://paste.upidapi.dev";
                  ping = href;
                };
              }
            ];
          }
          {
            Local = [
              {
                "Syncting" = {
                  icon = "syncthing.svg";
                  description = "Syncs files between machines";
                  href = "127.0.0.1:${toString ports.syncthing}";
                };
              }
            ];
          }
        ];
      };
    };
  };
}
