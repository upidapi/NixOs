{lib}: let
  inherit (lib) mkOption types;
in rec {
  mkOpt = type: default: description:
    mkOption {inherit type default description;};

  # opt whitout desc
  mkOpt' = type: default: mkOpt type default null;

  mkBoolOpt = mkOpt types.bool;

  mkBoolOpt' = mkOpt' types.bool;

  mkEnableOpt = desc: {enable = mkBoolOpt false desc;};

  enable = {enable = true;};
  disable = {enable = false;};
}
