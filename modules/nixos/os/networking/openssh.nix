{
  lib,
  my_lib,
  config,
  keys,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mapAttrs mkForce;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.system.security.openssh;
in {
  options.modules.nixos.system.security.openssh =
    mkEnableOpt "enable openssh to allow for remote ssh connections";

  config = mkIf cfg.enable {
    # TODO: make better https://github.com/Misterio77/nix-config/blob/4d678038f9631ab45993bbb7c362dc7122401246/hosts/common/global/openssh.nix#L30

    programs.ssh = {
      # ship github/gitlab/sourcehut host keys to avoid MiM (man in the middle) attacks
      knownHosts = mapAttrs (_: mkForce) (
        {
          github-rsa = {
            hostNames = ["github.com"];
            publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
          };

          github-ed25519 = {
            hostNames = ["github.com"];
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
          };

          gitlab-rsa = {
            hostNames = ["gitlab.com"];
            publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsj2bNKTBSpIYDEGk9KxsGh3mySTRgMtXL583qmBpzeQ+jqCMRgBqB98u3z++J1sKlXHWfM9dyhSevkMwSbhoR8XIq/U0tCNyokEi/ueaBMCvbcTHhO7FcwzY92WK4Yt0aGROY5qX2UKSeOvuP4D6TPqKF1onrSzH9bx9XUf2lEdWT/ia1NEKjunUqu1xOB/StKDHMoX4/OKyIzuS0q/T1zOATthvasJFoPrAjkohTyaDUz2LN5JoH839hViyEG82yB+MjcFV5MU3N1l1QL3cVUCh93xSaua1N85qivl+siMkPGbO5xR/En4iEY6K2XPASUEMaieWVNTRCtJ4S8H+9";
          };
          gitlab-ed25519 = {
            hostNames = ["gitlab.com"];
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
          };

          sourcehut-rsa = {
            hostNames = ["git.sr.ht"];
            publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZ+l/lvYmaeOAPeijHL8d4794Am0MOvmXPyvHTtrqvgmvCJB8pen/qkQX2S1fgl9VkMGSNxbp7NF7HmKgs5ajTGV9mB5A5zq+161lcp5+f1qmn3Dp1MWKp/AzejWXKW+dwPBd3kkudDBA1fa3uK6g1gK5nLw3qcuv/V4emX9zv3P2ZNlq9XRvBxGY2KzaCyCXVkL48RVTTJJnYbVdRuq8/jQkDRA8lHvGvKI+jqnljmZi2aIrK9OGT2gkCtfyTw2GvNDV6aZ0bEza7nDLU/I+xmByAOO79R1Uk4EYCvSc1WXDZqhiuO2sZRmVxa0pQSBDn1DB3rpvqPYW+UvKB3SOz";
          };

          sourcehut-ed25519 = {
            hostNames = ["git.sr.ht"];
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
          };
        }
        // (
          # Each hosts public key
          mapAttrs
          (hostname: key: {
            publicKey = key;
            extraHostNames =
              # Alias for localhost if it's the same host
              lib.optional (hostname == config.networking.hostName) "localhost";
          })
          (keys.machines)
        )
      );
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
      /**/
    };
    networking = {
      firewall = {
        allowedTCPPorts = [22];
      };
    };
  };
}
