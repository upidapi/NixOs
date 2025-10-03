{
  sonarr-old = {
    api_key = "@sonarr@";
    settings = {
      media_management = {
        root_folders = [
          "/mnt/shows"
          "/mnt/anime"
        ];
      };
      tags = {
        definitions = [
          "shows"
          "anime"
        ];
      };
      download_clients = {
        definitions = {
          "qBittorrent" = {
            type = "qbittorrent";
            host = "vpn";
            category = "sonarr";
          };
          "SABnzbd" = {
            type = "sabnzbd";
            host = "vpn";
            api_key = "@sabnzbd@";
            category = "sonarr";
          };
        };
      };
      security = {
        authentication = "form";
        username = "admin";
        password = "@password@";
      };
    };
  };


  sonarr = {            
    api_key = config.sops.secrets."sonarr/api-key".path;
    settings = {
      media_management = {
        root_folders = [
          "/mnt/shows"
          "/mnt/anime"
        ];
      };
      tags = {
        definitions = [
          "shows"
          "anime"
        ];
      };
      download_clients = {
        definitions = {
          "qBittorrent" = {
            type = "qbittorrent";
            host = "vpn";
            category = "sonarr";
          };
          "SABnzbd" = {
            type = "sabnzbd";
            host = "vpn";
            api_key = "@sabnzbd@";
            category = "sonarr";
          };
        };
      };
      security = {
        authentication = "form";
        username = "admin";
        password = "@password@";
      };
    };
  };

  radarr = {
    api_key = "@radarr@";
    settings = {
      media_management = {
        root_folders = {
          definitions = [
            "/mnt/movies"
          ];
        };
      };
      tags = {
        definitions = [
          "movies"
        ];
      };
      download_clients = {
        definitions = {
          "qBittorrent" = {
            type = "qbittorrent";
            hostname = "vpn";
            category = "radarr";
          };
          "SABnzbd" = {
            type = "sabnzbd";
            hostname = "vpn";
            api_key = "@sabnzbd@";
            category = "radarr";
          };
        };
      };
      security = {
        authentication = "form";
        username = "admin";
        password = "@password@";
      };
    };
  };

  prowlarr = {
    api_key = "@prowlarr@";
    settings = {
      indexers = {
        indexers = {
          definitions = {
            "NZBgeek" = {
              type = "newznab";
              sync_profile = "Standard";
              tags = [
                "shows"
                "anime"
                "movies"
              ];
              fields = {
                baseUrl = "https://api.nzbgeek.info";
              };
              secret_fields = {
                apiKey = "@nzbgeek@";
              };
            };
          };
        };
        proxies = {
          definitions = {
            "FlareSolverr" = {
              type = "flaresolverr";
              host_url = "http://flaresolverr:8191";
              tags = [
                "shows"
                "anime"
                "movies"
              ];
            };
          };
        };
      };
      apps = {
        applications = {
          definitions = {
            "Sonarr" = {
              type = "sonarr";
              prowlarr_url = "http://prowlarr:9696";
              base_url = "http://sonarr:8989";
              api_key = "@sonarr@";
              tags = [
                "shows"
                "anime"
              ];
            };
            "Radarr" = {
              type = "radarr";
              prowlarr_url = "http://prowlarr:9696";
              base_url = "http://radarr:7878";
              api_key = "@radarr@";
              tags = [
                "movies"
              ];
            };
          };
        };
      };
      download_clients = {
        definitions = {
          "qBittorrent" = {
            type = "qbittorrent";
            host = "vpn";
            username = "admin";
            password = "@password@";
            category = "prowlarr";
          };
          "SABnzbd" = {
            type = "sabnzbd";
            host = "vpn";
            api_key = "@sabnzbd@";
            category = "prowlarr";
          };
        };
      };
      tags = {
        definitions = [
          "shows"
          "anime"
          "movies"
        ];
      };
      security = {
        authentication = "form";
        username = "admin";
        password = "@password@";
      };
    };
  };

  jellyseerr = {
    api_key = "@jellyseerr@";
    settings = {
      general = {
        application_url = "https://jellyseerr.beannet.app";
      };
      jellyfin = {
        server_url = "http://jellyfin:8096";
        username = "admin";
        password = "@password@";
        email_address = "admin@beannet.app";
        libraries = [
          "Shows"
          "Anime"
          "Movies"
        ];
      };
      services = {
        sonarr = {
          definitions = {
            "Sonarr (HD)" = {
              is_default_server = true;
              is_4k_server = false;
              hostname = "sonarr";
              api_key = "@sonarr@";
              root_folder = "/mnt/shows";
              quality_profile = "HD-1080p";
              language_profile = "Deprecated";
              tags = ["shows"];
              anime_root_folder = "/mnt/anime";
              anime_quality_profile = "HD-1080p";
              anime_language_profile = "Deprecated";
              anime_tags = ["anime"];
              external_url = "https://sonarr.beannet.app";
              enable_season_folders = true;
              enable_scan = true;
              enable_automatic_search = true;
            };
            "Sonarr (4K)" = {
              is_default_server = true;
              is_4k_server = true;
              hostname = "sonarr";
              api_key = "@sonarr@";
              root_folder = "/mnt/shows";
              quality_profile = "Ultra-HD";
              language_profile = "Deprecated";
              tags = ["shows"];
              anime_root_folder = "/mnt/anime";
              anime_quality_profile = "Ultra-HD";
              anime_language_profile = "Deprecated";
              anime_tags = ["anime"];
              external_url = "https://sonarr.beannet.app";
              enable_season_folders = true;
              enable_scan = true;
              enable_automatic_search = true;
            };
          };
        };
        radarr = {
          definitions = {
            "Radarr (HD)" = {
              is_default_server = true;
              is_4k_server = false;
              hostname = "radarr";
              api_key = "@radarr@";
              root_folder = "/mnt/movies";
              quality_profile = "HD-1080p";
              minimum_availability = "released";
              tags = ["movies"];
              external_url = "https://radarr.beannet.app";
              enable_scan = true;
              enable_automatic_search = true;
            };
            "Radarr (4K)" = {
              is_default_server = true;
              is_4k_server = true;
              hostname = "radarr";
              api_key = "@radarr@";
              root_folder = "/mnt/movies";
              quality_profile = "Ultra-HD";
              minimum_availability = "released";
              tags = ["movies"];
              external_url = "https://radarr.beannet.app";
              enable_scan = true;
              enable_automatic_search = true;
            };
          };
        };
      };
    };
  };
}
