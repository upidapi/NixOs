{
  config,
  lib,
  my_lib,
  ports,
  self,
  ...
}: let
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
          title = "upidapi.dev - Yoooo";

          # theme = "dark";
          # color = "slate";
          background = {
            image = "https://images.unsplash.com/photo-1502790671504-542ad42d5189?auto=format&fit=crop&w=2560&q=80";
            # blur = "sm";
            # saturate = 100;
            # brightness = 50;
            # opacity = 100;
          };
          # cardBlur = "sm";

          theme = "dark";
          # color = "slate";
          target = "_blank"; # open in new tab
          statusStyle = "dot";
          cardBlur = "xs";

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
          };

          # headerStyle = "boxedWidgets";
          # target = "_self";

          # quicklaunch = {
          #   searchDescription = true;
          #   hideInternetSearch = true;
          #   showSearchSuggestions = true;
          #   hideVisitURL = true;
          # };
        };
        widgets = [
        ];
        services = [
          {
            Media = [
              {
                Jellyfin = {
                  icon = "jellyfin";
                  href = "https://jellyfin.upidapi.dev";
                  description = "Media Server";
                };
              }
              {
                Jellyseerr = {
                  icon = "jellyseerr";
                  href = "https://jellyseerr.upidapi.dev";
                  description = "Request Media Service";
                };
              }
            ];
          }
          {
            "Media Managment" = [
              {
                Sonarr = {
                  icon = "sonarr.svg";
                  href = "http://sonarr.upidapi.dev";
                  widget = {
                    type = "sonarr";
                    url = "http://localhost:${toString ports.sonarr}";
                    key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
                    # enableQueue = true;
                  };
                };
              }
              {
                Radarr = {
                  icon = "radarr.svg";
                  href = "http://radarr.upidapi.dev";
                  widget = {
                    type = "radarr";
                    url = "http://localhost:${toString ports.radarr}";
                    key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
                    # enableQueue = true;
                  };
                };
              }
              {
                Prowlarr = {
                  icon = "prowlarr.svg";
                  href = "http://prowlarr.upidapi.dev";
                  widget = {
                    type = "prowlarr";
                    url = "http://localhost:${toString ports.prowlarr}";
                    key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
                  };
                };
              }
              {
                qBittorrent = {
                  icon = "qbittorrent.svg";
                  href = "http://qbit.upidapi.dev";
                  widget = {
                    type = "qbittorrent";
                    url = "http://localhost:${toString ports.qbit}";
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
                "Paste Bin" = {
                  icon = "hastypaste.svg";
                  href = "http://paste.upidapi.dev";
                  description = "A private paste bin";
                };
              }
            ];
          }
        ];
      };
    };
  };
}
