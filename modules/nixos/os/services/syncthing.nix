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

    services.syncthing = let
      hostName = config.modules.nixos.meta.host-name;
      sopsSyncthing = val: config.sops.secrets."syncthing/${val}".path;

      devices = {
        "upinix-pc" = {id = "QZFGUG6-7SAQZA2-WLQN6PN-IW4VNKJ-34UFAA5-2WCECGU-G5TOXIF-HCSOYQ";};
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
        inherit devices;

        folders = {
          home-persist = {
            path = "~/persist";

            # devices = devIds;
            devices = ["upinix-pc"];

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

