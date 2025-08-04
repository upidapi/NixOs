{
  config,
  lib,
  mlib,
  inputs,
  pkgs,
  const,
  ...
}: let
  inherit (const) ports;
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt enableAnd;
  cfg = config.modules.nixos.homelab.media.qbit;
in {
  options.modules.nixos.homelab.media.qbit = mkEnableOpt "";

  config = mkIf cfg.enable {
    systemd.services.qbittorrent.vpnConfinement = enableAnd {
      vpnNamespace = "mullvad";
    };

    # TODO: maybe switch to proton vpn since mullvad doesnt support port
    #  forwarding, needed for good reseeding

    services.qbittorrent = {
      enable = true;
      group = "media";
      package = inputs.qbit.legacyPackages.${pkgs.system}.qbittorrent-nox;
      serverConfig = {
        LegalNotice.Accepted = true;
        BitTorrent.Session = {
          DefaultSavePath = "/raid/media/torrents";
          # TempPath = "/raid/media/torrents/tmp";

          Port = 43361; # should be port forewarded

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
  };
}
