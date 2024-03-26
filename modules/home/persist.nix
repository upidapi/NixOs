/* {
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt mkOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.persist;
in {
  options.modules.home.persist =
    (mkEnableOpt "whether or not to enable home file persistance") // {
      files =
    };

  config.boot.loader = mkIf cfg.enable {
    systemd-boot = {
      enable = true;
      editor = false;
    };

    efi.canTouchEfiVariables = true;
  };
} */
