{lib}: let
  inherit (lib) mkOption types;
in rec {
  mkOpt = type: default: description:
    mkOption {inherit type default description;};

  # opt without desc
  mkOpt' = type: default: mkOpt type default null;

  mkBoolOpt = mkOpt types.bool;

  mkEnableOpt = desc: {enable = mkOpt types.bool false desc;};

  enable = {enable = true;};
  disable = {enable = false;};

  enableAnd = cfg: cfg // enable;
  disableAnd = cfg: cfg // disable;
}
