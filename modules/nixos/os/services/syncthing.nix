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
    # its good to have a persistant place for stuff you dont
    # whant to sync, eg big downloaded iso(s)
    systemd.tmpfiles.settings = {
      "syncthing-ignore" = {
        "/home/upidapi/persist" = {
          d = {
            user = "upidapi";
            group = "users";
          };
        };
        "/home/upidapi/persist/.stignore" = {
          f = {
            user = "upidapi";
            group = "users";
            argument = "/local";
          };
        };
      };
    };

    # REF: https://github.com/tecosaur/golgi/blob/e48d5e47989c0e5e4c36676c2300d2c651948f54/modules/syncthing.nix#L60
    # REF: https://github.com/tecosaur/golgi/blob/e48d5e47989c0e5e4c36676c2300d2c651948f54/modules/caddy.nix#L9
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

    services.syncthing = let
      hostName = config.modules.nixos.meta.host-name;
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
