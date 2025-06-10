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
  cfg = config.modules.nixos.homelab.media.jellyseerr;
in {
  options.modules.nixos.homelab.media.jellyseerr = mkEnableOpt "";

  imports = [
    ./base.nix
  ];

  config = mkIf cfg.enable {
    # not needed since the templater has root perms
    sops.secrets = {
      #   "radarr/api-key_jellyseerr" = {
      #     key = "radarr/api-key";
      #     # owner = config.services.jellyseerr.user;
      #     sopsFile = "${self}/secrets/server.yaml";
      #   };
      #   "sonarr/api-key_jellyseerr" = {
      #     key = "sonarr/api-key";
      #     # owner = config.services.jellyseerr.user;
      #     sopsFile = "${self}/secrets/server.yaml";
      #   };
      "jellyseerr/api-key" = {
        key = "jellyseerr/api-key";
        # owner = config.services.jellyseerr.user;
        sopsFile = "${self}/secrets/server.yaml";
      };
      #   "jellyfin/jellyseerr-api-key_jellyseerr" = {
      #     key = "jellyfin/jellyseerr-api-key";
      #     # owner = config.services.jellyseerr.user;
      #     sopsFile = "${self}/secrets/server.yaml";
      #   };
    };

    # https://www.rapidseedbox.com/blog/jellyseerr-guide#01
    services.jellyseerr = {
      enable = true;
      port = ports.jellyseerr;
      # openFirewall = true;
      force = true;
      settings = {
        jellyfin = {
          apiKey = config.sops.placeholder."jellyfin/jellyseerr-api-key";
          externalHostname = "";
          ip = "127.0.0.1"; # or url
          jellyfinForgotPasswordUrl = "";
          libraries = [
            {
              enabled = true;
              # id = "f137a2dd21bbc1b99aa5c0f6bf02a805";
              name = "Movies";
              type = "movie";
            }
            {
              enabled = true;
              # id = "a656b907eb3a73532e40e44b968d0225";
              name = "Shows";
              type = "show";
            }
          ];
          name = "upinix-laptop";
          port = ports.jellyfin;
          # I don't think this is needed
          # serverId = "cd69c8b59e5b482eacf8ea3ff8c7f5ff";
          urlBase = "";
          useSsl = false;
        };
        main = {
          apiKey = config.sops.placeholder."jellyseerr/api-key";
          applicationTitle = "Jellyseerr";
          applicationUrl = "";
          cacheImages = false;
          defaultPermissions = 32;
          defaultQuotas = {
            movie = {};
            tv = {};
          };
          discoverRegion = "";
          enableSpecialEpisodes = false;
          hideAvailable = false;
          localLogin = true;
          locale = "en";
          mediaServerLogin = true;
          mediaServerType = 2;
          newPlexLogin = true;
          originalLanguage = "";
          partialRequestsEnabled = true;
          streamingRegion = "";
        };
        # plex = {
        #   ip = "";
        #   libraries = [];
        #   name = "";
        #   port = 32400;
        #   useSsl = false;
        # };
        public = {initialized = true;};
        radarr = [
          {
            activeDirectory = "/srv/radarr";
            activeProfileId = 1;
            activeProfileName = "Any";
            apiKey = config.sops.placeholder."radarr/api-key";
            hostname = "127.0.0.1";
            id = 0;
            is4k = false;
            isDefault = true;
            minimumAvailability = "released";
            name = "radarr";
            port = ports.radarr;
            preventSearch = false;
            syncEnabled = false;
            tagRequests = false;
            tags = [];
            useSsl = false;
          }
        ];
        sonarr = [
          {
            activeDirectory = "/srv/sonarr";
            activeProfileId = 1;
            activeProfileName = "Any";
            animeTags = [];
            apiKey = config.sops.placeholder."sonarr/api-key";
            enableSeasonFolders = false;
            hostname = "127.0.0.1";
            id = 0;
            is4k = false;
            isDefault = true;
            name = "sonarr";
            port = ports.sonarr;
            preventSearch = false;
            syncEnabled = false;
            tagRequests = false;
            tags = [];
            useSsl = false;
          }
        ];
        tautulli = {};
      };
    };
  };
}
