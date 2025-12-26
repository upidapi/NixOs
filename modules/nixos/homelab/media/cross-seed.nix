{
  config,
  lib,
  mlib,
  const,
  self,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  inherit (const) ports ips;
  cfg = config.modules.nixos.homelab.media.cross-seed;
in {
  options.modules.nixos.homelab.media.cross-seed = mkEnableOpt "";

  # REF: https://github.com/TheColorman/nixcfg/blob/4e624e15098a69d11ec86ad5da025bcc9d55c585/services/cross-seed.nix#L9
  # REF: https://github.com/carpenike/nix-config/blob/e4dd8817a048deb8216c52073f6764f72d0e6f2c/hosts/forge/services/cross-seed.nix#L30

  config = mkIf cfg.enable {
    services.cross-seed = {
      enable = true;
      settingsFile = config.sops.templates."cross-seed.settings.json".path;
      settings = {
        host = "0.0.0.0";
        port = ports.cross-seed;

        delay = 30; # Minimum allowed by cross-seed v6

        # Pure API mode: inject torrents directly via qBittorrent API
        # No filesystem paths needed - cross-seed uses API for everything
        dataDirs = [];
        linkDirs = [];

        # Match mode - "safe" prevents false positives
        matchMode = "safe";

        # Output directory - null for action=inject (API mode)
        outputDir = null;
      };
    };

    networking.firewall.interfaces."podman0".allowedTCPPorts = [
      config.services.cross-seed.settings.port
    ];

    # FIXME: (upstream) linkDirs require write access to create hardlinks
    systemd.services.cross-seed.serviceConfig.ReadWritePaths = [
      "/raid/media/torrents"
      "/mnt/neodata/autobrr/cross-seed"
    ];

    sops = {
      secrets = {
        "cross-seed/api-key" = {
          owner = config.services.prowlarr.user;
          sopsFile = "${self}/secrets/server.yaml";
        };
        "qbit/password_cross-seed" = {
          key = "qbit/password";
          owner = config.services.declarr.user;
          sopsFile = "${self}/secrets/server.yaml";
        };
        "radarr/api-key_cross-seed" = {
          owner = config.services.radarr.user;
          sopsFile = "${self}/secrets/server.yaml";
        };
        "lidarr/api-key_cross-seed" = {
          owner = config.services.lidarr.user;
          sopsFile = "${self}/secrets/server.yaml";
        };
        "sonarr/api-key_cross-seed" = {
          owner = config.services.sonarr.user;
          sopsFile = "${self}/secrets/server.yaml";
        };
        "prowlarr/api-key_cross-seed" = {
          owner = config.services.prowlarr.user;
          sopsFile = "${self}/secrets/server.yaml";
        };
      };
      templates."cross-seed.settings.json".content = let
        prowlarrPort = toString ports.prowlarr;
        sonarrPort = toString ports.sonarr;
        radarrPort = toString ports.radarr;
        qbitPort = toString ports.qbit;

        crossSeedKey = config.sops.placeholder."cross-seed/api-key";
        prowlarrKey = config.sops.placeholder."prowlarr/api-key_cross-seed";
        sonarrKey = config.sops.placeholder."sonarr/api-key_cross-seed";
        radarrKey = config.sops.placeholder."radarr/api-key_cross-seed";

        qbitUser = "admin";
        qbitPass = config.sops.placeholder."qbit/password_cross-seed";
      in
        builtins.toJSON {
          notificationWebhookUrls = [];

          apiKey = crossSeedKey;
          torznab = [
            # BROKEN: the indexes are the ids, will change on recreation
            #  "fun"
            "http://localhost:${prowlarrPort}/700/api?apikey=${prowlarrKey}" # TL
            # "http://localhost:${prowlarrPort}/700/api?apikey=${prowlarrKey}" # TL
          ];
          sonarr = "http://localhost:${sonarrPort}?apikey=${sonarrKey}";
          radarr = "http://localhost:${radarrPort}?apikey=${radarrKey}";

          torrentClients = [
            "qbittorrent:http://${qbitUser}:${qbitPass}@${ips.proton}:${qbitPort}"
          ];
        };
    };
  };
}
