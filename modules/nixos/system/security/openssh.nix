{
  lib,
  my_lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.security.openssh;
in {
  options.modules.nixos.security.openssh =
    mkEnableOpt "enable openssh to allow for remote ssh connections";

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [22];
      settings = {
        PasswordAuthentication = true;
        AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
        UseDns = true;
        PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
      };
    };

    networking = {
      firewall = {
        allowedTCPPorts = [22];
      };
    };

    services.fail2ban = {
      enable = true;
      ignoreIP = ["192.168.0.101"];

      maxretry = 10;
      bantime = "1m";
      bantime-increment = {
        enable = true;
        multipliers = "1 2 5 10 15 30 60 120 360 720";
        rndtime = "5m";
      };

      /*
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
      */
    };
  };
}
