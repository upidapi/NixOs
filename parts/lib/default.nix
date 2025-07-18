args: rec {
  opt = import ./opt.nix args;
  misc = import ./misc.nix args;
  script = import ./scripts.nix args;

  inherit
    (misc)
    mapStylixColors
    lPadString
    rPadString
    toPrivateStateDirectory
    ;

  inherit
    (script)
    writeShellApplicationCompletions
    ;

  inherit
    (opt)
    mkOpt
    mkOpt'
    mkEnableOpt
    enable
    disable
    enableAnd
    disableAnd
    ;
}
