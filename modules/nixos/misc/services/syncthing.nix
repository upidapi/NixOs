{
  config,
  lib,
  mlib,
  const,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.misc.services.syncthing;
in {
  options.modules.nixos.misc.services.syncthing = mkEnableOpt "enables syncing";

  # Syncthing prevents suspend during sync
  #   also affects restic

  # Fixed by not using bindfs to mount the /home/upidapi/persist
  #   I suspect that the reason for the bug is that the bind mount is
  #   removed before the systemd service is stopped. Maybe this can be
  #   avoided but i prefer just not using bindfs since it has significant
  #   performance costs

  # Reproducible way to cause the bug
  #   click rescan all (in the web gui)
  #   >>> systemctl suspend

  # Maybe related to
  #   https://forum.syncthing.net/t/syncthing-prevents-linux-suspend/12885/6

  # Things that didn't fix it:
  #
  #   systemd.services."syncthing" = {
  #     before = ["suspend.target" "sleep.target" "hibernate.target"];
  #     after = ["resumed.target"];
  #     wantedBy = ["suspend.target" "sleep.target" "hibernate.target"];
  #     serviceConfig = {
  #       ExecStop = "systemctl stop syncthing.service";
  #     };
  #   };
  #
  #   # Nor adding to all system fuse mounts
  #   fileSystems = {
  #     "/".options = ["x-systemd.device-timeout=200ms"];
  #     "/persist".options = ["x-systemd.device-timeout=200ms"];
  #   };

  config = mkIf cfg.enable {
    sops.secrets = {
      "syncthing/cert" = {
        owner = "upidapi";
        restartUnits = ["syncthing.service"];
      };

      "syncthing/key" = {
        owner = "upidapi";
        restartUnits = ["syncthing.service"];
      };
    };

    # make syncthing ignore /home/upidapi/persist/tmp
    # its good to have a persistent place for stuff you don't
    # want to sync, eg big downloaded iso(s)
    systemd.tmpfiles.settings = {
      "syncthing-ignore" = {
        # prevent race condition for creating it
        # otherwise the creation of .config/syncthing might cause .config
        # to be owned by root
        "/home/upidapi/.config" = {
          d = {
            user = "upidapi";
            group = "users";
          };
        };
        "/home/upidapi/persist" = {
          d = {
            user = "upidapi";
            group = "users";
          };
        };
        "/home/upidapi/persist/.stignore" = {
          w = {
            user = "upidapi";
            group = "users";
            argument = ''
              /local
              /vms

              // keep contens of /prog/projects, but not contens of subdirs
              /prog/projects/*/*
              !/prog/projects/*

              /prog/ref/*/*
              !/prog/ref/*

              /prog/*/*
            '';
          };
        };
      };
    };

    services.syncthing = let
      # hostName = config.modules.nixos.meta.host-name;
      sopsSyncthing = val: config.sops.secrets."syncthing/${val}".path;

      devices = {
        "upinix-pc" = {id = "LBLCHUP-C47KTSD-YXKTUZ3-LCNYNTP-A5OT3CK-TBVBUJB-QS7VPSZ-F6KPOQ5";};
        "upinix-laptop" = {id = "YEIKVCN-GJS66FE-UWHXB3F-K7CNXSH-X6QPMIB-SZ5TDMD-NUGRF5H-PCAZIQB";};
      };
      devIds = lib.attrNames devices;
    in {
      enable = true;
      # is this necessary
      cert = sopsSyncthing "cert";
      key = sopsSyncthing "key";

      # Hardcoding the user is a sub optimal. But its necessary unless i want
      # to finish the home manager version and solve its problems.
      # https://nitinpassa.com/running-syncthing-as-a-system-user-on-nixos/
      dataDir = "/home/upidapi";
      user = "upidapi";
      group = "users";

      guiAddress = "127.0.0.1:${toString const.ports.syncthing}";

      settings = {
        # dont send usage reports
        urAccepted = -1;

        inherit devices;

        options = {
          urAccepted = -1; # no anonymous usage data
        };

        folders = {
          home-persist = {
            path = "~/persist";

            devices = devIds;
            # devices = ["upinix-pc"];

            versioning = {
              type = "staggered";
              params = {
                # clean old versions once an hour
                cleanInterval = toString (60 * 60);

                # no versions older than one month
                maxAge = toString (30 * 24 * 60 * 60);
              };
            };
          };
        };
      };
    };
  };
}
