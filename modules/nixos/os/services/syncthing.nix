{
  config,
  lib,
  my_lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.os.services.syncthing;
in {
  options.modules.nixos.os.services.syncthing = mkEnableOpt "enables syncing";

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

    # maybe fix the suspend issue?
    # doesnt seem like it
    # systemd.services."syncthing" = {
    #   before = ["suspend.target" "sleep.target" "hibernate.target"];
    #   after = ["resumed.target"];
    #   wantedBy = ["suspend.target" "sleep.target" "hibernate.target"];
    #   serviceConfig = {
    #     ExecStop = "systemctl stop syncthing.service";
    #   };
    # };

    # FIXME: Syncthing seems to sometimes syncthing prevents linux suspend
    #  on laptop lid close
    #  https://forum.syncthing.net/t/syncthing-prevents-linux-suspend/12885/6
    #  lid close / systemctl suspend

    # NOTE: currently I've disabled syncthing to avoid this

    # Adding this to the file config should fix it (nope)
    # "x-systemd.device-timeout=200ms

    # reproducible way to cause the bug
    #  click rescan all (in the web gui)
    #  >>> systemctl suspend

    # I think this fixes it (nope)
    # fileSystems = {
    #   "/".options = ["x-systemd.device-timeout=200ms"];
    #   "/persist".options = ["x-systemd.device-timeout=200ms"];
    # };

    # REF: https://github.com/tecosaur/golgi/blob/e48d5e47989c0e5e4c36676c2300d2c651948f54/modules/syncthing.nix#L60
    # REF: https://github.com/tecosaur/golgi/blob/e48d5e47989c0e5e4c36676c2300d2c651948f54/modules/caddy.nix#L9
    /*
        services.caddy.virtualHosts."syncthing.localhost" = {
          #         import ${config.sops.templates.cf-tls.path}

          extraConfig = let
            addr = toString config.services.syncthing.guiAddress;
          in ''
            reverse_proxy ${addr}
            # tls internal
            # reverse_proxy ${addr} {
            #   header_up Host {upstream_hostport}
            # }
          '';
        };
    e
    */

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
      # is this necisary
      cert = sopsSyncthing "cert";
      key = sopsSyncthing "key";

      # Hardcoding the user is a sub optimal. But its necicary unless i whant
      # to finish the home manager version and solve its problems
      dataDir = "/home/upidapi";
      user = "upidapi";
      group = "users";

      settings = {
        # dont send usage reports
        urAccepted = -1;

        inherit devices;

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
