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

    services.qbittorrent = {
      enable = true;
      group = "media";
      package = inputs.qbit.legacyPackages.${pkgs.system}.qbittorrent-nox;
      serverConfig = {
        LegalNotice.Accepted = true;
        BitTorrent.Session = {
          DefaultSavePath = "/media/torrents";
          # TempPath = "/media/torrents/tmp";
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
