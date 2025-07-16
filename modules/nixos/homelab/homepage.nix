{
  config,
  lib,
  my_lib,
  ports,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.homelab.homepage;
in {
  options.modules.nixos.homelab.homepage = mkEnableOpt "";

  config = mkIf cfg.enable {
    services = {
      caddy.virtualHosts = {
        # "upidapi.dev".extraConfig = ''
        # '';
        "upidapi.dev".extraConfig = ''
          import harden_headers

          reverse_proxy localhost:${toString ports.homepage}
        '';
      };

      sops.templates."homepage-env".content = ''
        SONARR_API_KEY=${config.sops.placeholder."sonarr/api-key"}
        RADARR_API_KEY=${config.sops.placeholder."radarr/api-key"}
        PROWLARR_API_KEY=${config.sops.placeholder."prowlarr/api-key"}
      '';

      # REF: https://github.com/Cody-W-Tucker/nix-config/blob/804d2e768ceb469e020a42cfb0318c3171bd1c93/modules/server/homepage-dashboard.nix#L16
      # REF: https://github.com/wi11-holdsworth/dots/blob/499755444a6a5c7f0883355430461c45d34cdee2/modules/nixos/features/homepage-dashboard.nix#L25

      homepage-dashboard = {
        enable = true;
        environmentFile = config.sops.templates."homepage-env".path;
        listenPort = ports.homepage;
        openFirewall = false;
        allowedHosts = "upidapi.dev";
        settings = {
          title = "upidapi.dev - Yoooooooooooo";
          cardBlur = "sm";
          # layout = {
          #   Business = {
          #     style = "row";
          #     columns = 3;
          #   };
          #   Tools = {
          #     style = "row";
          #     columns = 4;
          #   };
          # };
          headerStyle = "boxedWidgets";
          target = "_self";
          quicklaunch = {
            searchDescription = true;
            hideInternetSearch = true;
            showSearchSuggestions = true;
            hideVisitURL = true;
          };
        };
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

            "Media Managment" = [
              {
                Sonarr = {
                  icon = "sonarr.svg";
                  href = "http://sonarr.upidapi.dev";
                  widget = {
                    type = "sonarr";
                    url = "http://localhost:${toString ports.sonarr}";
                    key = "{{SONARR_API_KEY}}";
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
                    key = "{{RADARR_API_KEY}}";
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
                    key = "{{PROWLARR_API_KEY}}";
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
                  };
                };
              }
            ];

            Misc = [
              {
                "Paste Bin" = {
                  icon = "hastypaste.svg";
                  href = "paste.upidapi.dev";
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
