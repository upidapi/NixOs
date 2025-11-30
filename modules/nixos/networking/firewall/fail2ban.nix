{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.os.networking.firewall.fail2ban;
in {
  options.modules.nixos.os.networking.firewall.fail2ban =
    mkEnableOpt "enables fail2ban to protect agains openssh attacks";

  config = mkIf cfg.enable {
    services = {
      fail2ban = {
        enable = true;
        ignoreIP = ["192.168.0.101"];

        maxretry = 10;
        bantime = "1m";
        bantime-increment = {
          enable = true;
          multipliers = "1 2 5 10 15 30 60 120 360 720";
          rndtime = "5m";
        };
        jails = {
          DEFAULT.settings.findtime = "15m";

          sshd = lib.mkForce ''
            enabled = true
            mode = aggressive
            port = ${
              lib.strings.concatMapStringsSep
              ","
              toString
              config.services.openssh.ports
            }
          '';
        };
      };
    };
  };
}
