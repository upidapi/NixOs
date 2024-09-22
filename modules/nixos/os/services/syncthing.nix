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

    # TODO: setup nginx for creating the local servers (and for the ssh stuff)
    # TODO: setup caddy? (web server cert thingy?)
    # TODO: setup ldap?
    services.syncthing = let
      hostName = config.modules.nixos.meta.host-name;
      sopsSyncthing = val: config.sops.secrets."syncthing/${val}".path;

      devices = {
        # "upinix-pc" = {id = "5XJNULB-MTBCLG3-TVAES2C-HRBGR3M-5JJ5MEL-EHI6LLQ-QP4S6BI-BNT24AA";};
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

    # TODO: caddy
    # ref: https://github.com/rishid/nix-config/blob/30ecd28045cb47b7792cacfa20e0596b56c02529/modules/vaultwarden/default.nix#L73
  };
}
# referance
/*
{
  config,
  lib,
  data,
  user,
  ...
}:
let
  cfg = config.services'.syncthing;
  port = 8384;

  inherit (config.networking) hostName;

  hosts = lib.filterAttrs (n: v: v.syncthing) data.hosts;

  authMode = if config.services'.ldap.enable then "ldap" else "static";

  mkFolder = name: devices: {
    ${name} = {
      path = "~/${name}";
      inherit devices;
      versioning = {
        type = "staggered";
        params = {
          cleanInterval = "3600";
          maxAge = "2592000";
        };
      };
    };
  };

  mkDevice = name: id: {
    ${name} = {
      inherit id;
      addresses = [ "dynamic" ];
    };
  };

  devices = lib.concatMapAttrs (host: hostData: mkDevice host hostData.syncthing_id) hosts;
  folders = lib.concatMapAttrs (name: devices: mkFolder name devices) {
    "Archives" = lib.attrNames devices;
    "Documents" = lib.attrNames devices;
    "Pictures" = lib.attrNames devices;
  };

in
{
  options.services'.syncthing.enable = lib.mkEnableOption' { };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      cert = config.sops.secrets."syncthing/cert".path;
      key = config.sops.secrets."syncthing/key".path;

      settings = {
        options.urAccepted = -1;

        gui = {
          inherit authMode;
        };

        ldap = {
          address = "localhost:3890";
          bindDN = "cn=%s,ou=people,dc=snakepi,dc=xyz";
          transport = "nontls";
          searchBaseDN = "ou=people,dc=snakepi,dc=xyz";
          searchFilter = "(&(uid=%s)(memberof=cn=lldap_syncthing,ou=groups,dc=snakepi,dc=xyz))";
        };

        inherit devices folders;
      };

      guiAddress = "127.0.0.1:${toString port}";
      inherit user;
      group = "users";
      dataDir = config.users.users.${user}.home;
    };

    services.caddy.virtualHosts.syncthing = {
      hostName = "sync.snakepi.xyz";
      extraConfig = ''
        import ${config.sops.templates.cf-tls.path}

        reverse_proxy 127.0.0.1:${toString port} {
          header_up Host {upstream_hostport}
        }
      '';
    };

    sops.secrets = {
      "syncthing/cert" = {
        key = "hosts/${hostName}/syncthing_key_pair/cert";
        owner = user;
        restartUnits = [ "syncthing.service" ];
      };

      "syncthing/key" = {
        key = "hosts/${hostName}/syncthing_key_pair/key";
        owner = user;
        restartUnits = [ "syncthing.service" ];
      };
    };

    environment.persistence."/persist" = {
      users.${user}.directories = [ ".config/syncthing" ];
    };
  };
}
*/

