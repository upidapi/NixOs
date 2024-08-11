{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.modules.nixos.hardware.monitors;
in {
  options.modules.nixos.hardware.monitors = {
    primaryMonitor = mkOption {
      type = types.str;
      default =
        (builtins.elemAt (
            builtins.filter
            (m: m.primary)
            (builtins.attrValues cfg.monitors)
          )
          0)
        .name;
    };

    monitors = mkOption {
      type = types.attrsOf (types.submodule ({name, ...}: {
        options = {
          name = mkOption {
            type = types.str;
            default = name;
            example = "DP-1";
          };
          primary = mkOption {
            type = types.bool;
            default = false;
          };
          width = mkOption {
            type = types.int;
            example = 1920;
          };
          height = mkOption {
            type = types.int;
            example = 1080;
          };
          refreshRate = mkOption {
            type = types.int;
            default = 60;
          };
          x = mkOption {
            type = types.int;
            default = 0;
          };
          y = mkOption {
            type = types.int;
            default = 0;
          };
          enabled = mkOption {
            type = types.bool;
            default = true;
          };
          scale = mkOption {
            type = types.oneOf [types.float types.int];
            default = 1;
          };

          # workspace id (1 <= id <= 10)
          workspace = mkOption {
            type = types.int;
          };
        };
      }));
      default = [];
    };
  };

  config = {
    assertions = [
      {
        assertion =
          (lib.length (builtins.attrValues cfg.monitors) != 0)
          -> (
            (
              lib.length (
                lib.filter
                (m: m.primary)
                (builtins.attrValues cfg.monitors)
              )
            )
            == 1
          );
        message = "Exactly one monitor must be set to primary. ${
          builtins.toJSON cfg.monitors
        }";
      }
      # {
      #   assertion = (lib.length cfg) != 0;
      #   message = "No monitors configured";
      # }
    ];
  };
}
