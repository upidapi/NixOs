{
  lib,
  my_lib,
  config,
  keys,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.system.security.openssh;
in {
  options.modules.nixos.system.security.openssh =
    mkEnableOpt "enable openssh to allow for remote ssh connections";

  config = mkIf cfg.enable {
    # TODO: make better https://github.com/Misterio77/nix-config/blob/4d678038f9631ab45993bbb7c362dc7122401246/hosts/common/global/openssh.nix#L30

    programs.ssh = {
      # Each hosts public key

      # FIXME:
      /*
      knownHosts =
        lib.genAttrs
        (config.modules.nixos.hosts)
        (hostname: {
          publicKeyFile = pkgs.writeText "${hostname}_key.pub" keys.machines."${hostname}";
          extraHostNames =
            # Alias for localhost if it's the same host
            lib.optional (hostname == config.networking.hostName) "localhost";
        });
      */
    };

    services = {
      openssh = {
        enable = true;
        ports = [22];
        hostKeys = [
          {
            path = "/persist/system/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];
        settings = {
          PasswordAuthentication = true;
          AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
          UseDns = true;
          # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
          PermitRootLogin = "prohibit-password";
        };
      };
      /*
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
      */
    };
    networking = {
      firewall = {
        allowedTCPPorts = [22];
      };
    };
  };
}
