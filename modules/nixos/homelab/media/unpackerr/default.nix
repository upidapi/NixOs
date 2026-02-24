{
  config,
  lib,
  mlib,
  const,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  inherit (const) ports;
  cfg = config.modules.nixos.homelab.media.unpackerr;
in {
  options.modules.nixos.homelab.media.unpackerr = mkEnableOpt "";

  imports = [
    ./base.nix
  ];

  config = mkIf cfg.enable {
    sops.templates."unpackerr-env".content = ''
      UN_SONARR_0_API_KEY=${config.sops.placeholder."sonarr/api-key"}
      UN_RADARR_0_API_KEY=${config.sops.placeholder."radarr/api-key"}
    '';

    users.users.unpackerr.extraGroups = ["qbittorrent"];
    services.unpackerr = {
      enable = true;
      # group = "media";

      environmentFile = config.sops.templates."unpackerr-env".path;

      settings = {
        debug = true;
        quiet = false;
        error_stderr = false;
        activity = false;

        log_queues = "1m";

        # Logging
        # log_file = "/var/lib/unpackerr/log.txt";
        log_files = 10;
        log_file_mb = 10;

        # Timing
        interval = "2m";
        start_delay = "1m";
        retry_delay = "5m";
        max_retries = 3;

        parallel = 1;

        file_mode = "0644";

        dir_mode = "0755";

        # Starr apps (all disabled, matching commented TOML)
        lidarr = [];
        radarr = [
          {
            url = "http://127.0.0.1:${toString ports.radarr}";
            # api_key = "0123456789abcdef0123456789abcdef";
            paths = ["/raid/media/torrents"];
            # protocols = "torrent";
            # timeout = "10s";
            # delete_delay = "5m";
            # delete_orig = false;
            # syncthing = false;
          }
        ];
        readarr = [];
        sonarr = [
          {
            url = "http://127.0.0.1:${toString ports.sonarr}";
            # api_key = "0123456789abcdef0123456789abcdef";
            paths = ["/raid/media/torrents"];
            # protocols = "torrent";
            # timeout = "10s";
            # delete_delay = "5m";
            # delete_orig = false;
            # syncthing = false;
          }
        ];
        whisparr = [];

        # Optional sections disabled
        webhook = [];
        # watch folders
        folder = [
          # {
          #   path = "/some/folder/to/watch";
          #   extract_path = "";
          #   delete_after = "10m";
          #   disable_recursion = false;
          #   delete_files = false;
          #   delete_original = false;
          #   disable_log = false;
          #   move_back = false;
          #   extract_isos = false;
          #   interval = "2m";
          # }
        ];
        cmdhook = [];

        # Webserver disabled
        webserver = {
          # metrics = false; # implicit by not enabling
        };
      };
    };
  };
}
