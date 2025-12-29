{
  config,
  lib,
  mlib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types mkOption;
  inherit (mlib) mkEnableOpt;
  cfg = config.services.thelounge;
in {
  options.services.thelounge = {
    users = mkOption {
      type = types.attrsOf (types.submodule ({name, ...}: {
        options = {
          name = mkOption {
            default = name;
            type = types.str;
          };
          logs = mkOption {
            default = true;
            type = types.bool;
          };
          passwordFile = mkOption {
            type = types.path;
          };
        };
      }));
    };
  };

  config = mkIf cfg.enable {
    systemd.services.thelounge.serviceConfig = let
      dataDir = "/var/lib/thelounge";
    in {
      ExecStartPre = pkgs.writeShellScript "setup-thelounge-scripts" ''
        # hardcoded in the module
        mkdir -p ${dataDir}/users

        create_user() {
          local cfg="$1"
          local name="$2"
          local password="$(cat $3)"
          local pswHash="$(
            ${pkgs.apacheHttpd}/bin/htpasswd -bnBC 11 "" "$password" |
            ${pkgs.coreutils}/bin/tr -d ':\n'
          )"

          ${pkgs.jq}/bin/jq -n \
            --argjson cfg "$cfg" \
            --arg password "$pswHash" \
            '$cfg + {password: $password}' \
            > "${dataDir}/users/$name.json"
        }

        ${lib.concatStringsSep "\n" (
          lib.map
          (u: "create_user ${
            lib.escapeShellArgs [
              (builtins.toJSON {log = u.logs;})
              u.name
              u.passwordFile
            ]
          }")
          (lib.attrValues cfg.users)
        )}
      '';
    };
  };
}
