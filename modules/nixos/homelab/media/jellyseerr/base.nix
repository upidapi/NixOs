{
  config,
  lib,
  pkgs,
  inputs',
  ...
}: let
  inherit
    (lib)
    mkOption
    types
    mkIf
    ;

  cfg = config.services.jellyseerr;
in {
  options.services.jellyseerr = {
    config = mkOption {
      type = types.attrs;
      default = {};
    };
    # for compat
    dataDir = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      default = cfg.configDir;
    };
  };

  config = let
    jellyseerr-cfg = {
      jellyseerr =
        lib.recursiveUpdate {
          declarr = {
            type = "jellyseerr";
            inherit (cfg) port;
            stateDir = cfg.configDir;
          };
        }
        cfg.config;
    };
    cfg-file =
      pkgs.writeText
      "jellyseerr-config.yaml"
      (builtins.toJSON jellyseerr-cfg);

    jellyseerr-init = pkgs.writeShellApplication {
      name = "jellyseerr-init";
      runtimeInputs = [cfg.package];
      checkPhase = ''
        runHook preCheck
        runHook postCheck
      '';
      text = ''
        ${inputs'.declarr.packages.declarr}/bin/declarr \
          --sync \
          --run jellyseerr \
          ${cfg-file}
      '';
    };
  in
    mkIf cfg.enable {
      systemd.services.jellyseerr = {
        after = ["jellyfin.service"];
        serviceConfig = {
          # DynamicUser = false;
          ExecStart = lib.mkForce (lib.getExe jellyseerr-init);
        };
      };
    };
}
